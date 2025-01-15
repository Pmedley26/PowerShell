function Install-Software {
[Cmdletbinding()]
param(
[parameter(Mandatory)]
[ValidateSet('1','2')] 
[string]$Version ,

[parameter(Mandatory , ValuefromPipeline)]
[string]$Computername 

) 

process {
Write-host "I installed software version $Version on $Computername."
}


}

$computers = @("SRV1", "SRV2", "SRV3")
$computers | Install-Software -Version 2




