$computers = @('Mac-Winserver2022','WINDOWS-1UEN9EP','WIN-2HVM0AQ4KOB')
get-content -Path "\\$($computers[0])\c$\app_configuration.txt"
get-content -Path "\\$($computers[1])\c$\app_configuration.txt"
get-content -Path "\\$($computers[2])\c$\app_configuration.txt"

#If and Else Statement
if (Test-Connection -ComputerName $computers[1] -Quiet -Count 1) {
Get-Content -Path "\\$($computers[1])\c$\app_configuration.txt"
} else {
Write-Error -Message "The server $($computers[1]) is not responding!"
}
