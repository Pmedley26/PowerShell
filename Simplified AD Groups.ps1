Import-Module ActiveDirectory

$SourceUser = Read-Host "Enter source SamAccountName"
$TargetUser = Read-Host "Enter target SamAccountName"

$Source = Get-ADUser $SourceUser -Properties MemberOf
$Target = Get-ADUser $TargetUser

$Groups = $Source.MemberOf
$TargetGroups = (Get-aduser $TargetUser -Properties MemberOf).MemberOf


foreach ($Group in $Groups) {
if ($TargetGroups -notcontains $Group) {


    Add-ADGroupMember -Identity $Group -Members $Target

    Write-Host "Added $TargetUser to $Group"
}
}

# Practice Syntax

$Source = Get-ADUser pmedley -Properties Memberof
$Source.Memberof

$Groups.GetType()

Get-aduser pmedley -properties MemberOf,PrimaryGroupID

Get-ADGroup "RD Access Users" -Properties Member
Add-ADGroupMember -Identity "RD Access Users" -Members "pmedley"

Get-ADgroup "RD Access Users" -properties Member | Export-csv -path C:\Users\pmedley\Documents\RDAccess.csv