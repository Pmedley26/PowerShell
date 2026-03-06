$ServerAddress = "austell-ga-pbmwjhpppj.dynamic-m.com"
$ConnectionName = "UFI VPN 3"
$PresharedKey = "MerakiUFI"

Add-VpnConnection -Name "$ConnectionName" -ServerAddress "$ServerAddress" -TunnelType L2tp -L2tpPsk "$PresharedKey" -AuthenticationMethod Pap -Force