
New-NetFirewallRule -DisplayName "Allow TCP Port 8448" -Direction Inbound -Protocol TCP -LocalPort 8448 -Action Allow
New-NetFirewallRule -DisplayName "Allow TCP Port 8008" -Direction Inbound -Protocol TCP -LocalPort 8008 -Action Allow
New-NetFirewallRule -DisplayName "Allow TCP Port 6667" -Direction Inbound -Protocol TCP -LocalPort 6667 -Action Allow
New-NetFirewallRule -DisplayName "Allow TCP Port 9005" -Direction Inbound -Protocol TCP -LocalPort 9005 -Action Allow
New-NetFirewallRule -DisplayName "Allow TCP Port 29334" -Direction Inbound -Protocol TCP -LocalPort 29334 -Action Allow

# 