$rows = Import-Csv -path C:\Users\Administrator\Documents\IPAddresses.csv

foreach($row in $rows) {
try {
$output = @{
IpAddress = $row.IPAddress
Department = $row.Department
IsOnline = $false
HostName = $null
Error = $null
} 

if (Test-connection -ComputerName $row.IPAddress -Count 1 -Quiet) {
$output.IsOnline = $true
}

if ($hostname = (Resolve-DnsName -Name $row.IPAddress -ErrorAction Stop).Name) {
$output.Hostname = $hostName
}
} catch {
$output.Error = $_.Exception.Message
} finally {
[pscustomobject]$output
}

}

