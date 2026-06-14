Import-Module ActiveDirectory

$DaysInactive = 30
$CutoffDate = (Get-Date).AddDays(-$DaysInactive)

$InactiveUsers = Get-ADUser -Filter * -Properties LastLogonDate, Enabled |
    Where-Object {
        $_.Enabled -eq $true -and
        (
            $_.LastLogonDate -lt $CutoffDate -or
            $_.LastLogonDate -eq $null
        )
    } |
    Select-Object Name, SamAccountName, Enabled, LastLogonDate

$InactiveUsers