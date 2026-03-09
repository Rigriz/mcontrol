$interface = "Ethernet"
$dnsServers = ("172.16.17.5","8.8.8.8")

Set-DnsClientServerAddress -InterfaceAlias $interface -ServerAddresses $dnsServers