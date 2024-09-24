# Values
$IP = "192.168.103.185"
$GW = "192.168.103.190"  # AANGEPAST -> 190 voor no HSRP
$DNS = "192.168.103.185"  
$InterfaceName = "Ethernet"# "Ethernet 2" als je met Internal Network werkt
$AdminPassword = ConvertTo-SecureString -String "23Admin24" -AsPlainText -Force

#IPv6
$IP6 = "2001:db8:ac03:42::FFFA"
$GW6 = "2001:db8:ac03:42::FFFF"
$DNS6 = "2001:db8:ac03:42::FFFA"

# Keyboard Layout
Set-WinUserLanguageList -LanguageList nl-BE -Force

# Static IPv4 IP instellen
New-NetIPAddress -InterfaceAlias $InterfaceName -IPAddress $IP -AddressFamily IPv4 -PrefixLength 27 -DefaultGateway $GW
Set-DnsClientServerAddress -InterfaceAlias $InterfaceName -ServerAddresses $DNS

# Static IPv6 IP instellen
New-NetIPAddress -InterfaceAlias $InterfaceName -IPAddress $IP6 -AddressFamily IPv6 -PrefixLength 64 -DefaultGateway $GW6
Set-DnsClientServerAddress -InterfaceAlias $InterfaceName -ServerAddresses $DNS6

# icmpv4 rule
netsh advfirewall firewall add rule name="ping4" protocol=icmpv4:8,any dir=in action=allow
netsh advfirewall firewall add rule name="ping4" protocol=icmpv4:8,any dir=out action=allow

netsh advfirewall firewall add rule name="ping4" protocol=icmpv6:8,any dir=in action=allow
netsh advfirewall firewall add rule name="ping4" protocol=icmpv6:8,any dir=out action=allow

# Kerberos

# TCP Port 88:
New-NetFirewallRule -DisplayName "Allow Kerberos TCP Inbound" -Direction Inbound -Protocol TCP -LocalPort 88 -Action Allow -Profile Domain

# UDP Port 88:
New-NetFirewallRule -DisplayName "Allow Kerberos UDP Inbound" -Direction Inbound -Protocol UDP -LocalPort 88 -Action Allow -Profile Domain
    
# TCP Port 88:
New-NetFirewallRule -DisplayName "Allow Kerberos TCP Outbound" -Direction Outbound -Protocol TCP -LocalPort 88 -Action Allow -Profile Domain

# UDP Port 88:
New-NetFirewallRule -DisplayName "Allow Kerberos UDP Outbound" -Direction Outbound -Protocol UDP -LocalPort 88 -Action Allow -Profile Domain

# WinRM

netsh advfirewall firewall add rule name="WinRM HTTP" protocol=TCP dir=in localport=5985 action=allow
netsh advfirewall firewall add rule name="WinRM HTTPS" protocol=TCP dir=in localport=5986 action=allow

# AD Feature Installatie
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools -verbose

Import-Module ADDSDeployment

Write-Host "Forest installeren"

#ad.g03-fft.internal -> aanpassing

Install-ADDSForest `
    -DomainName "ad.g03-fft.internal" `
    -DomainMode "WinThreshold" `
    -DomainNetbiosName "G03fft" `
    -ForestMode "WinThreshold" `
    -InstallDns:$true `
    -SafeModeAdministratorPassword $AdminPassword `
    -CreateDnsDelegation:$false `
    -DatabasePath "C:\Windows\NTDS" `
    -LogPath "C:\Windows\NTDS" `
    -NoRebootOnCompletion:$false `
    -SysvolPath "C:\Windows\SYSVOL" `
    -Force:$true

Restart-Computer

