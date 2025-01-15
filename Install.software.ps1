function Install-Software {
[Cmdletbinding()]
param(
[parameter(Mandatory)]
[ValidateSet('1','2')]
[string]$Version ,

[Parameter(Mandatory, ValueFromPipeline)]
[string]$ComputerName
)

# A default value can be added for the parameter block. The above shows version 2 for the default
# By adding the Mandatory attribute with the parameter block, you requie a version to be specified for the function to work. 
Write-host "I installed software version $Version on $ComputerName"
}

$computers = @("SRV1", "SRV2", "SRV3")
foreach ($pc in $computers) {

Install-Software version 2 -ComputerName $pc
}