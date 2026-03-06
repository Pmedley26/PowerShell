$ServerAddress = "austell-ga-nkvrqwkjpj.dynamic-m.com"
$ConnectionName = "UFI VPN"
$PresharedKey = "MerakiUFI"

Add-VpnConnection -Name "$ConnectionName" -ServerAddress "$ServerAddress" -TunnelType L2tp -L2tpPsk "$PresharedKey" -AuthenticationMethod Pap -Force