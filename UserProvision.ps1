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
[int]$EmployeeNumber

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
if (-not ($ou = Get-ADOrganizationalUnit -Filter "Name -eq '$Department'")) {
throw "The Active Directory OU for department [$($Department)] could not be found."
} elseif (-not (Get-ADGroup -Filter "Name -eq '$Department'")) {
throw "The group {$($Department)] does not exist."
} else {
Add-Type -AssemblyName 'System.Web'
$password = [System.Web.Security.Membership]::GeneratePassword((Get-Random -Minimum 10 -Maximum 25), 3)
$secPW = ConvertTo-SecureString -String $password -AsPlainText -Force

$newUserParams = @{
GivenName    = $FirstName
EmployeeNumber = $EmployeeNumber
Department =     $Department
Name =           $userName
Accountpassword  = $secPW
ChangePasswordAtLogon  = $true
Enabled    = $true
Confirm  = $false
}

if ($PSCmdlet.ShouldProcess("AD user [$username]", "Create AD user $FirstName $LastName")) {
New-ADUser @newUserParams


Add-ADGroupMember -Identity $Department -Members $userName

[pscustomobject]@{
FirstName = $FirstName
LastName = $Lastname
Employeenumber = $EmployeeNumber
Department = $Department
Password = [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($secPw))
}
}
}



} catch {
Write-Error -Message $_.Exception.Message
}


