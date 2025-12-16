#requires -Module ActiveDirectory
[CmdletBinding()]
param (
[Parameter(Mandatory)]
[string]$FirstName,

[Parameter(Mandatory)]
[string]$LastName,

[parameter(Mandatory)]
[string]$Department, 

[parameter(Mandatory)]
[string]$Title,

[parameter(Mandatory)]
[string]$Manager,

[parameter(Mandatory)]
[string]$UserPrincipalName,

[parameter(Mandatory)]
[string]$DisplayName,

[parameter(Mandatory)]
[string]$samAccountname,

[parameter(Mandatory)]
[string]$MobilePhone,

[parameter(Mandatory)]
[string]$Company

)


try {
$userName = '{0}{1}' -f $FirstName.Substring(0,1), $LastName
$i = 2
while ((Get-aduser -Filter "samAccountName -eq '$userName'") -and ($userName -notlike "$FirstName*")) {
Write-Warning -Message "The username [$($userName)] already exists. Trying another..."
$userName = '{0}{1}' -f $FirstName.Substring(0, $i), $LastName
Start-Sleep -Seconds 1
$i++
}

Add-Type -AssemblyName 'System.Web'
$password = [System.Web.Security.Membership]::GeneratePassword((Get-Random -Minimum 10 -Maximum 25), 3)
$secPW = ConvertTo-SecureString -String $password -AsPlainText -Force

$NewUser = @{
GivenName    = $FirstName
Surname =      $Lastname
Department =     $Department
Name =           $userName
Title =           $Title
Manager = $Manager
Displayname = $DisplayName
UserprincipalName = $UserPrincipalName
samAccountName = $samAccountname
Company = $Company
Mobilephone = $MobilePhone
Accountpassword  = $secPW
ChangePasswordAtLogon  = $true
Enabled    = $true
Confirm  = $false
Path =  "OU=Final Fantasy 7,DC=MacAD2022,DC=local"
}

if ($PSCmdlet.ShouldProcess("AD user [$username]", "Create AD user $FirstName $LastName")) {
New-ADUser @NewUser



[pscustomobject]@{
FirstName = $FirstName
LastName = $Lastname
Title = $Title
Manager = $Manager
Department = $Department
Displayname = $DisplayName
samAccountname = $samAccountname
Company = $Company
UserPrincipalName = $UserPrincipalname
Mobilephone = $MobilePhone
Password = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($secPw))
}
}




} catch {
Write-Error -Message $_.Exception.Message
}

$groups = "Testgroup", "TestGroup2"
$result = $NewUser

foreach ($group in $groups) {
try { 
Add-ADGroupMember -Identity $Group -Members $NewUser.samAccountName  -ErrorAction stop
Write-host "New User added to group '$group' successfully."
} catch {
Write-Warning "Failed to add user to group '$group'. Error: $($_.Exception.Message)"

}

}


