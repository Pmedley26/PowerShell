$folderpath = '.\bogusFolder'
try {
$files = Get-Childitem -Path $folderPath -ErrorAction Stop
Write-Host "This shouldn't run."
$files.foreach({
$fileText = Get-Content $files
$fileText[0]
})
} catch {
$_.Exception.Message
}
