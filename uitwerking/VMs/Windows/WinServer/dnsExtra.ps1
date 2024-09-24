$InterfaceName = "Ethernet"
$DNS = "192.168.103.185" 
$DNS6 = "2001:db8:ac03:42::FFFA"

Set-DnsClientServerAddress -InterfaceAlias $InterfaceName -ServerAddresses $DNS
Set-DnsClientServerAddress -InterfaceAlias $InterfaceName -ServerAddresses $DNS6

# Website

Add-DnsServerPrimaryZone -Name "g03-fft.internal" -ZoneFile "g03-fft.internal.dns"
# Add-DnsServerResourceRecordA -ZoneName "g03-fft.internal" -Name "@" -IPv4Address "192.168.103.155"
Add-DnsServerResourceRecordAAAA -ZoneName "g03-fft.internal" -Name "@" -IPv6Address "2001:db8:ac03:13::FFFC"
# Get-DnsServerResourceRecord -ZoneName "g03-fft.internal" -RRType "A"
Get-DnsServerResourceRecord -ZoneName "g03-fft.internal" -RRType "AAAA"

Add-DnsServerResourceRecordCName -ZoneName "g03-fft.internal" -Name "www" -HostNameAlias "g03-fft.internal"
Get-DnsServerResourceRecord -ZoneName "g03-fft.internal" -RRType "CNAME"

# Extra website uitbereiding

Add-DnsServerPrimaryZone -Name "extra.g03-fft.internal" -ZoneFile "extra.g03-fft.internal.dns"
# Add-DnsServerResourceRecordA -ZoneName "extra.g03-fft.internal" -Name "@" -IPv4Address "192.168.103.155"
Add-DnsServerResourceRecordAAAA -ZoneName "extra.g03-fft.internal" -Name "@" -IPv6Address "2001:db8:ac03:13::FFFC"
# Get-DnsServerResourceRecord -ZoneName "extra.g03-fft.internal" -RRType "A"
Get-DnsServerResourceRecord -ZoneName "extra.g03-fft.internal" -RRType "AAAA"

# Add-DnsServerResourceRecordCName -ZoneName "extra.g03-fft.internal" -Name "www" -HostNameAlias "extra.g03-fft.internal"
# Get-DnsServerResourceRecord -ZoneName "extra.g03-fft.internal" -RRType "CNAME"

# Nextcloud

Add-DnsServerPrimaryZone -Name "nextcloud.g03-fft.internal" -ZoneFile "nextcloud.g03-fft.internal.dns"
# Add-DnsServerResourceRecordA -ZoneName "nextcloud.g03-fft.internal" -Name "@" -IPv4Address "192.168.103.155"
Add-DnsServerResourceRecordAAAA -ZoneName "nextcloud.g03-fft.internal" -Name "@" -IPv6Address "2001:db8:ac03:13::FFFC"
# Get-DnsServerResourceRecord -ZoneName "nextcloud.g03-fft.internal" -RRType "A"
Get-DnsServerResourceRecord -ZoneName "nextcloud.g03-fft.internal" -RRType "AAAA"

# Add-DnsServerResourceRecordCName -ZoneName "nextcloud.g03-fft.internal" -Name "www" -HostNameAlias "nextcloud.g03-fft.internal"
# Get-DnsServerResourceRecord -ZoneName "nextcloud.g03-fft.internal" -RRType "CNAME"

# Matrix.org
Add-DnsServerPrimaryZone -Name "matrix.g03-fft.internal" -ZoneFile "matrix.g03-fft.internal.dns"
# Add-DnsServerResourceRecordA -ZoneName "matrix.g03-fft.internal" -Name "@" -IPv4Address "192.168.103.155"
Add-DnsServerResourceRecordAAAA -ZoneName "matrix.g03-fft.internal" -Name "@" -IPv6Address "2001:db8:ac03:13::FFFC"
# Get-DnsServerResourceRecord -ZoneName "matrix.g03-fft.internal" -RRType "A"
Get-DnsServerResourceRecord -ZoneName "matrix.g03-fft.internal" -RRType "AAAA"

# Add-DnsServerResourceRecordCName -ZoneName "matrix.g03-fft.internal" -Name "www" -HostNameAlias "matrix.g03-fft.internal"
# Get-DnsServerResourceRecord -ZoneName "matrix.g03-fft.internal" -RRType "CNAME"