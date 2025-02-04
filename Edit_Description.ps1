$Users = Get-ADUser -Filter * 

$Users | ForEach-Object {
Set-ADUser -Identity $_ -Description "Test AD Account"
}