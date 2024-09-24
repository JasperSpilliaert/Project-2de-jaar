# Toetsenbordindeling
Set-WinUserLanguageList -LanguageList nl-BE -Force

# Installeren van de RSAT-tools voor grafisch overzicht serverconfig

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

netsh advfirewall firewall add rule name="WinRM HTTP" protocol=TCP dir=out localport=5985 action=allow
netsh advfirewall firewall add rule name="WinRM HTTPS" protocol=TCP dir=out localport=5986 action=allow

# RSAT-tools installeren (internet required)
# $installedRSAT = Get-WindowsCapability -Name RSAT* -Online | Where-Object { $_.State -eq "Installed" }

# if (!$installedRSAT) {
#     Write-Host "RSAT-tools worden geïnstalleerd..."
#     # Lijst van RSAT-tools
#     $RsatFeatures = @(
#         "Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0",
#         "Rsat.GroupPolicy.Management.Tools~~~~0.0.1.0",
#         "Rsat.ServerManager.Tools~~~~0.0.1.0"
#     )
#     foreach ($Feature in $RsatFeatures) {
#         Add-WindowsCapability -Online -Name $Feature -Verbose
#     }
#     Write-Host "RSAT-tools zijn geïnstalleerd."
# }
# else {
#     Write-Host "RSAT-tools zijn al geïnstalleerd."
# }

# Stop the Windows Update Service:
# Stop-Service -Name wuauserv -Force

# Set the Windows Update Service to Disabled:
# Set-Service -Name wuauserv -StartupType Disabled