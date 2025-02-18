$User = Read-Host -Prompt "Enter Username"
$groups = "Legal Employees", "O365 Licensed Employees", "MTech All"

foreach ($group in $groups) {
try {
Add-ADGroupMember -Identity $group -Members $User -Erroraction stop
Write-Host "User '$user' added to group '$group' successfully."
} catch {
Write-Warning "Failed to add user '$User' to group '$group'. Error: $($_.Exception.Message)"

}


} 