#Offboarding Script
[CmdletBinding()]

param(
[Parameter(Mandatory)]
[string]$samAccountName

)






#Disable the user's Account
set-aduser -Identity $samAccountName -Enabled $False


# Move to disabled users OU based on distinguished name
$user = Get-ADObject -Filter { samAccountName -eq $samAccountName } -Properties DistinguishedName
$targetOU = "OU=Disabled Users,DC=domain,DC=mtech,DC=com"
Move-ADObject -Identity $user.DistinguishedName -TargetPath $targetOU




#Setting variable and removing user from requested groups
$grouptokeep = "CN=O365 Licensed Employees,OU=Managed Security Groups,DC=domain,DC=mtech,DC=com"
$targetuser = Get-ADUser -Identity $samAccountname -Property MemberOf
$groupsToRemove = $targetuser.MemberOf | Where-Object { $_ -ne $groupToKeep }

foreach ($group in $groupsToRemove) {
    Remove-ADGroupMember -Identity $group -Members $targetuser -Confirm:$False

    } 




#Resetting to Random Password
Add-Type -AssemblyName 'System.Web'
$password = [System.Web.Security.Membership]::GeneratePassword((Get-Random -Minimum 14 -Maximum 25), 3)
$secPW = ConvertTo-SecureString -String $password -AsPlainText -Force


#Parameter Block for offboarded user

$disableduser = @{
samaccountname = $samAccountName
AccountPassword = $secPW

}

[pscustomobject]@{
samAccountname = $samAccountname
Password = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($secPw))
}



