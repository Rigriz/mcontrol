$interface = "Ethernet"
$dnsServers = ("172.16.23.74","8.8.8.8")

Set-DnsClientServerAddress -InterfaceAlias $interface -ServerAddresses $dnsServers