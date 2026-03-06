:: Install all VPN connections sequentially

@echo off
ECHO Running Script 1...
powershell.exe -ExecutionPolicy Bypass -File "\\ufifile1\01-Current\IT\Installation\VPN\UFIVPN-1.ps1" -Command "& {Write-Host 'Script 1 finished'; Start-Sleep -Seconds 2}"

ECHO Running Script 2...
powershell.exe -ExecutionPolicy Bypass -File "\\ufifile1\01-Current\IT\Installation\VPN\UFIVPN-2.ps1" -Command "& {Write-Host 'Script 1 finished'; Start-Sleep -Seconds 2}"

ECHO Running Script 2...
powershell.exe -ExecutionPolicy Bypass -File "\\ufifile1\01-Current\IT\Installation\VPN\UFIVPN-3.ps1" -Command "& {Write-Host 'Script 1 finished'; Start-Sleep -Seconds 2}"

ECHO All scripts finished.
pause
