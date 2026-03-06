$ServerAddress = "austell-ga-gdhpmvvjpj.dynamic-m.com"
$ConnectionName = "UFI VPN 2"
$PresharedKey = "MerakiUFI"

Add-VpnConnection -Name "$ConnectionName" -ServerAddress "$ServerAddress" -TunnelType L2tp -L2tpPsk "$PresharedKey" -AuthenticationMethod Pap -Force