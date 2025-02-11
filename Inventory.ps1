$rows = Import-Csv -path C:\Users\Administrator\Documents\IPAddresses.csv


#Create Hashtable specifying IP, Department, Is the IP Reachable, What is hostname, and How to handle Errors. 
foreach($row in $rows) {
try {
$output = @{
IpAddress = $row.IPAddress
Department = $row.Department
IsOnline = $false
HostName = $null
Error = $null
} 

#Ping IP address from csv once, if reachable, set hashtable value to true
if (Test-connection -ComputerName $row.IPAddress -Count 1 -Quiet) {
$output.IsOnline = $true
}

#Check if Hostname can be found, and update hashtable value if found. 
if ($hostname = (Resolve-DnsName -Name $row.IPAddress -ErrorAction Stop).Name) {
$output.Hostname = $hostName
}
} catch {
$output.Error = $_.Exception.Message

#Create a PScustomobject to which the output of the script will save, allowing the CSV to be exported
} finally {
[pscustomobject]$output
}

}

