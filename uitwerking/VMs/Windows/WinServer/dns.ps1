$domainName = "ad.g03-fft.internal"
$aRecordsPath = "C:\Users\Administrator\Downloads\A-records.csv"
$cnameRecordsPath = "C:\Users\Administrator\Downloads\CNAME-records.csv"
$ptrRecordsPath = "C:\Users\Administrator\Downloads\PTR-records.csv"
$aaaaRecordsPath = "C:\Users\Administrator\Downloads\AAAA-records.csv"
$ipv6PtrRecordsPath = "C:\Users\Administrator\Downloads\IPv6-PTR-records.csv"
$forwarderIP = "8.8.8.8" 

# importeren van A-records en creëren van PTR-records
function Import-ARecordsAndPTRRecords {
    Import-Csv -Path $aRecordsPath | ForEach-Object {
        Write-Host "Adding A-record for $($_.HostName) with IP $($_.IPAddress)"
        Add-DnsServerResourceRecordA -ZoneName $domainName -Name $_.HostName -IPv4Address $_.IPAddress # -CreatePtr
    }
    Import-Csv -Path $ptrRecordsPath | ForEach-Object {
        Write-Host "Adding PTR-record for $($_.IPAddress) with HostName $($_.HostName)"
        Add-DnsServerResourceRecordPtr -ZoneName $domainName -Name $_.HostName -PtrDomainName $_.IPAddress
    }
}

# Functie voor het importeren van AAAA-records en het creëren van PTR-records (IPv6)
function Import-AAAARecordsAndPTRRecords {
    Import-Csv -Path $aaaaRecordsPath | ForEach-Object {
        Write-Host "Adding AAAA-record for $($_.HostName) with IPv6 $($_.IPv6Address)"
        Add-DnsServerResourceRecordAAAA -ZoneName $domainName -Name $_.HostName -IPv6Address $_.IPv6Address
    }
    Import-Csv -Path $ipv6PtrRecordsPath | ForEach-Object {
        Write-Host "Adding IPv6 PTR-record for $($_.IPv6Address) with HostName $($_.HostName)"
        # Berekenen van de omgekeerde IPv6-notatie
        $reversedIPv6 = ($_.IPv6Address.split(':')[-1] -split "(..)" | ? { $_ })[-1..0] -join '.'
        Add-DnsServerResourceRecordPtr -ZoneName "f.f.3.0.c.a.8.b.d.0.1.0.0.2.ip6.arpa" -Name $reversedIPv6 -PtrDomainName $_.HostName
    }
}

# Functie voor het importeren van CNAME-records
function Import-CNAMERecords {
    Import-Csv -Path $cnameRecordsPath | ForEach-Object {
        Write-Host "Adding CNAME-record: $($_.AliasName) pointing to $($_.TargetName)"
        Add-DnsServerResourceRecordCName -ZoneName $domainName -Name $_.AliasName -HostNameAlias $_.TargetName
    }
}

# Functie voor het instellen van een DNS-forwarder
function Set-DNSForwarder {
    Write-Host "Setting DNS forwarder to $forwarderIP"
    Set-DnsServerForwarder -IPAddress $forwarderIP
}

# Hoofdscript
try { 
    Add-DnsServerPrimaryZone -Name "103.168.192.in-addr.arpa" -ReplicationScope "Domain" -DynamicUpdate "Secure"
    Write-Host "IPv4 reverse lookup zone succesvol aangemaakt."
} catch {
    Write-Host "Probleem met Reverse lookup zone: $_"
}

try {
    Add-DnsServerPrimaryZone -Name "f.f.3.0.c.a.8.b.d.0.1.0.0.2.ip6.arpa" -ReplicationScope "Domain" -DynamicUpdate "Secure"
    Write-Host "IPv6 reverse lookup zone succesvol aangemaakt."
} catch {
    Write-Host "Probleem met Reverse lookup zone voor IPv6: $_"
}

Import-ARecordsAndPTRRecords
Import-AAAARecordsAndPTRRecords
Import-CNAMERecords
Set-DNSForwarder
Write-Host "DNS configuration complete."

