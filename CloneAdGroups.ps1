
<#
.SYNOPSIS
    Clones AD group memberships from one user to another.

.PARAMETER SourceSamAccountName
    The SAM account name (logon name) of the source user whose groups will be copied.

.PARAMETER TargetSamAccountName
    The SAM account name (logon name) of the target user who will be added to the same groups.

.PARAMETER IncludeNested
    If specified, includes nested groups (i.e., expands indirect memberships).

.PARAMETER WhatIf
    Performs a dry run showing what would happen without making changes.

.PARAMETER LogPath
    Path to a CSV log file (created if it doesn't exist).

.EXAMPLE
    .\Clone-AdUserGroups.ps1 -SourceSamAccountName jdoe -TargetSamAccountName asmith -Verbose

.EXAMPLE
    .\Clone-AdUserGroups.ps1 -SourceSamAccountName jdoe -TargetSamAccountName asmith -IncludeNested -WhatIf

.NOTES
    Requires RSAT ActiveDirectory module. Run with appropriate privileges.
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory)]
    [string]$SourceSamAccountName,

    [Parameter(Mandatory)]
    [string]$TargetSamAccountName,

    [switch]$IncludeNested,

    [string]$LogPath = ".\Clone-AdUserGroups-log.csv"
)

function Ensure-AdModule {
    if (-not (Get-Module -Name ActiveDirectory -ListAvailable)) {
        throw "ActiveDirectory module not found. Install RSAT / Active Directory module and try again."
    }
    Import-Module ActiveDirectory -ErrorAction Stop
}

function Get-UserWithValidation {
    param(
        [Parameter(Mandatory)][string]$Sam
    )
    $user = Get-ADUser -Identity $Sam -Properties memberOf, PrimaryGroupID -ErrorAction Stop
    if (-not $user) { throw "User '$Sam' not found." }
    return $user
}

function Get-PrimaryGroupDn {
    param(
        [Parameter(Mandatory)]$User
    )
    # Resolve primary group via RID math
    $domainSid = (Get-ADDomain).DomainSID.Value
    $primaryGroupSid = "$domainSid-$($User.PrimaryGroupID)"
    $primaryGroup = Get-ADGroup -Filter "objectSid -eq '$primaryGroupSid'" -ErrorAction SilentlyContinue
    return $primaryGroup.DistinguishedName
}

function Get-UserGroups {
    param(
        [Parameter(Mandatory)]$User,
        [switch]$ExpandNested
    )

    if ($ExpandNested) {
        # Get indirect memberships by enumerating group-of-user memberships and expanding upwards
        # Start with direct group DNs
        $directGroupDns = $User.memberOf
        $allGroupDns = [System.Collections.Generic.HashSet[string]]::new()

        foreach ($dn in $directGroupDns) { [void]$allGroupDns.Add($dn) }

        # BFS upward via 'memberOf' to capture nested memberships
        $queue = [System.Collections.Generic.Queue[string]]::new()
        foreach ($dn in $directGroupDns) { $queue.Enqueue($dn) }

        while ($queue.Count -gt 0) {
            $currentDn = $queue.Dequeue()
            $g = Get-ADGroup -Identity $currentDn -Properties memberOf -ErrorAction SilentlyContinue
            if ($null -ne $g -and $g.memberOf) {
                foreach ($parentDn in $g.memberOf) {
                    if (-not $allGroupDns.Contains($parentDn)) {
                        [void]$allGroupDns.Add($parentDn)
                        $queue.Enqueue($parentDn)
                    }
                }
            }
        }
        return [string[]]$allGroupDns
    }
    else {
        # Direct memberships only
        return [string[]]$User.memberOf
    }
}

function Init-Log {
    param([string]$Path)
    if (-not (Test-Path -Path $Path)) {
        "Timestamp,SourceUser,TargetUser,GroupCN,GroupDN,Action,Status,Message" | Out-File -FilePath $Path -Encoding UTF8
    }
}

function Write-Log {
    param(
        [string]$Path,
        [string]$SourceUser,
        [string]$TargetUser,
        [string]$GroupCN,
        [string]$GroupDN,
        [string]$Action,
        [string]$Status,
        [string]$Message
    )
    $line = ('{0},{1},{2},"{3}","{4}",{5},{6},"{7}"' -f
        (Get-Date).ToString("s"),
        $SourceUser,
        $TargetUser,
        $GroupCN,
        $GroupDN,
        $Action,
        $Status,
        $Message.Replace('"','""')
    )
    Add-Content -Path $Path -Value $line
}

try {
    Ensure-AdModule

    $src = Get-UserWithValidation -Sam $SourceSamAccountName
    $tgt = Get-UserWithValidation -Sam $TargetSamAccountName

    if ($src.DistinguishedName -eq $tgt.DistinguishedName) {
        throw "Source and target users are the same account. Aborting."
    }

    Init-Log -Path $LogPath

    Write-Verbose "Resolving primary group for '$($src.SamAccountName)'..."
    $primaryGroupDn = Get-PrimaryGroupDn -User $src

    Write-Verbose "Collecting group memberships (IncludeNested: $($IncludeNested.IsPresent))..."
    $groupDns = Get-UserGroups -User $src -ExpandNested:$IncludeNested

    # Filter out primary group (cannot add via Add-ADGroupMember)
    $groupDns = $groupDns | Where-Object { $_ -ne $primaryGroupDn }

    if (-not $groupDns -or $groupDns.Count -eq 0) {
        Write-Warning "No eligible groups found on source user (after filtering primary group)."
        return
    }

    # Build a set of target user's current groups to avoid duplicates
    $tgtGroups = (Get-ADUser -Identity $tgt -Properties memberOf).memberOf
    $tgtGroupSet = [System.Collections.Generic.HashSet[string]]::new()
    foreach ($dn in $tgtGroups) { [void]$tgtGroupSet.Add($dn) }

    Write-Verbose "Processing $($groupDns.Count) group(s)..."
    foreach ($groupDn in $groupDns) {
        $group = Get-ADGroup -Identity $groupDn -Properties CN, groupCategory, groupScope -ErrorAction SilentlyContinue
        if ($null -eq $group) {
            Write-Warning "Could not resolve group: $groupDn"
            Write-Log -Path $LogPath -SourceUser $src.SamAccountName -TargetUser $tgt.SamAccountName `
                -GroupCN "" -GroupDN $groupDn -Action "Add" -Status "Failed" -Message "Group not found"
            continue
        }

        $cn = $group.CN
        $alreadyMember = $tgtGroupSet.Contains($groupDn)

        if ($alreadyMember) {
            Write-Verbose "SKIP: Target already in '$cn'"
            Write-Log -Path $LogPath -SourceUser $src.SamAccountName -TargetUser $tgt.SamAccountName `
                -GroupCN $cn -GroupDN $groupDn -Action "Skip" -Status "AlreadyMember" -Message "No change"
            continue
        }

        $actionDesc = "Add '$($tgt.SamAccountName)' to group '$cn' ($($group.groupCategory) / $($group.groupScope))"
        if ($PSCmdlet.ShouldProcess($cn, $actionDesc)) {
            try {
                Add-ADGroupMember -Identity $group.DistinguishedName -Members $tgt.DistinguishedName -ErrorAction Stop
                Write-Verbose "ADDED: $actionDesc"
                Write-Log -Path $LogPath -SourceUser $src.SamAccountName -TargetUser $tgt.SamAccountName `
                    -GroupCN $cn -GroupDN $groupDn -Action "Add" -Status "Success" -Message "Added"
            }
            catch {
                Write-Warning "FAILED to add '$($tgt.SamAccountName)' to '$cn': $($_.Exception.Message)"
                Write-Log -Path $LogPath -SourceUser $src.SamAccountName -TargetUser $tgt.SamAccountName `
                    -GroupCN $cn -GroupDN $groupDn -Action "Add" -Status "Failed" -Message $_.Exception.Message
            }
        }
        else {
            # When -WhatIf is used, ShouldProcess logs plan but we also record it.
            Write-Log -Path $LogPath -SourceUser $src.SamAccountName -TargetUser $tgt.SamAccountName `
                -GroupCN $cn -GroupDN $groupDn -Action "Add" -Status "Planned" -Message "WhatIf"
        }
    }

    Write-Host "Done. Log: $LogPath" -ForegroundColor Green
}
catch {
    Write-Error $_.Exception.Message
    if ($LogPath) {
        Write-Log -Path $LogPath -SourceUser $SourceSamAccountName -TargetUser $TargetSamAccountName `
            -GroupCN "" -GroupDN "" -Action "Script" -Status "Failed" -Message $_.Exception.Message
    }
}
``
