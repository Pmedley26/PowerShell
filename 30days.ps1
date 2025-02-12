$today = Get-Date
$30daysago = $today.AddDays(-30)
Get-Aduser -Filter "Enabled -eq 'true' -and passwordlastset -lt '$30daysago'"
