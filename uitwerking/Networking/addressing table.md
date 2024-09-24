# Addressing table
This is the addressing table for our System Engineering Project, both **IPv4** and **IPv6** can be found here.

## <u>IPv4</u>
Assigned network address: **192.168.103.0 /24**
### Subnetting
|Name                  |ID |# hosts     |Network address |Usable range                      |Broadcast address|Subnet               |
|:---------------------|:--|-----------:|:--------------:|:--------------------------------:|:---------------:|:-------------------:|
|Network management    |1  |14 hosts    |192.168.103.128 |192.168.103.129<br>192.168.103.142|192.168.103.143  |255.255.255.240 (/28)|
|Werkstations employees|11 |126 hosts   |192.168.103.0   |192.168.103.1<br>192.168.103.126  |192.168.103.127  |255.255.255.128 (/25)|
|DMZ                   |13 |14 hosts    |192.168.103.144 |192.168.103.145<br>192.168.103.158|192.168.103.159  |255.255.255.240 (/28)|
|Interne servers       |42 |30 hosts    |192.168.103.160 |192.168.103.161<br>192.168.103.190|192.168.103.191  |255.255.255.224 (/27)|
|ISP-Interfaces        |N/A|6 hosts     |192.168.103.248 |192.168.103.249<br>192.168.103.254|192.168.103.255  |255.255.255.248 (/29)|

### Addressing
|Device                |Interface|VLAN|IP-address     |Subnet               |Default Gateway                                    |
|:---------------------|--------:|:---|:-------------:|:-------------------:|:-------------------------------------------------:|
|ISP Router            |G0/0     |N/A |192.168.103.254|255.255.255.248 (/29)|N/A                                                |
|Router 1              |G0/0     |N/A |192.168.103.252|255.255.255.248 (/29)|N/A                                                |
|                      |G0/1.1   |1   |192.168.103.141|255.255.255.240 (/28)|N/A                                                |
|                      |G0/1.11  |1   |192.168.103.125|255.255.255.128 (/25)|N/A                                                |
|                      |G0/1.13  |13  |192.168.103.157|255.255.255.240 (/28)|N/A                                                |
|                      |G0/1.42  |42  |192.168.103.189|255.255.255.224 (/27)|N/A                                                |
|Router 1 (BackUp)     |G0/0     |N/A |192.168.103.251|255.255.255.248 (/29)|N/A                                                |
|                      |G0/1.1   |1   |192.168.103.140|255.255.255.240 (/28)|N/A                                                |
|                      |G0/1.11  |1   |192.168.103.124|255.255.255.128 (/25)|N/A                                                |
|                      |G0/1.13  |13  |192.168.103.156|255.255.255.240 (/28)|N/A                                                |
|                      |G0/1.42  |42  |192.168.103.188|255.255.255.224 (/27)|N/A                                                |
|Virtuele router (HSRP)|G0/0     |N/A |192.168.103.253|255.255.255.248 (/29)|N/A                                                |
|                      |VLAN 1   |1   |192.168.103.142|255.255.255.240 (/28)|N/A                                                |
|                      |VLAN 11  |11  |192.168.103.126|255.255.255.128 (/25)|N/A                                                |
|                      |VLAN 13  |13  |192.168.103.158|255.255.255.240 (/28)|N/A                                                |
|                      |VLAN 42  |42  |192.168.103.190|255.255.255.224 (/27)|N/A                                                |
|Switch 1              |VLAN 1   |1   |192.168.103.139|255.255.255.240 (/28)|192.168.103.142 (HSRP)<br>192.168.103.141 (NO HSRP)|
|TFTP                  |Fa0      |1   |192.168.103.138|255.255.255.240 (/28)|192.168.103.142 (HSRP)<br>192.168.103.141 (NO HSRP)|
|Proxy                 |Fa0      |13  |192.168.103.155|255.255.255.240 (/28)|192.168.103.158 (HSRP)<br>192.168.103.157 (NO HSRP)|
|CA Server             |Fa0      |13  |192.168.103.154|255.255.255.240 (/28)|192.168.103.158 (HSRP)<br>192.168.103.157 (NO HSRP)|
|LinuxCLI (DB)         |Fa0      |42  |192.168.103.187|255.255.255.224 (/27)|192.168.103.190 (HSRP)<br>192.168.103.189 (NO HSRP)|
|LinuxCLI (Web)        |Fa0      |42  |192.168.103.186|255.255.255.224 (/27)|192.168.103.190 (HSRP)<br>192.168.103.189 (NO HSRP)|
|WinServ (DC)          |Fa0      |42  |192.168.103.185|255.255.255.224 (/27)|192.168.103.190 (HSRP)<br>192.168.103.189 (NO HSRP)|
|LinuxCLI (matrix.org) |Fa0      |42  |192.168.103.184|255.255.255.224 (/27)|192.168.103.190 (HSRP)<br>192.168.103.189 (NO HSRP)|
|LinuxCLI (Nextcloud)  |Fa0      |42  |192.168.103.183|255.255.255.224 (/27)|192.168.103.190 (HSRP)<br>192.168.103.189 (NO HSRP)|
|LinuxCLI (Web-BackUp) |Fa0      |42  |192.168.103.182|255.255.255.224 (/27)|192.168.103.190 (HSRP)<br>192.168.103.189 (NO HSRP)|



## <u>IPv6</u>
Assigned network addres: **2001:db8:ac03::/48**
### Subnetting
|Name                  |ID |Network address     |Usable range                                     |Subnet mask|
|:---------------------|:--|:------------------:|:-----------------------------------------------:|:---------:|
|Network management    |1  |2001:db8:ac03:1::   |2001:db8:ac03:1::1<br>2001:db8:ac03:1::FFFF      |/64        |
|Werkstations employees|11 |2001:db8:ac03:11::  |2001:db8:ac03:11::1<br>2001:db8:ac03:11::FFFF    |/64        |
|DMZ                   |13 |2001:db8:ac03:13::  |2001:db8:ac03:13::1<br>2001:db8:ac03:13::FFFF    |/64        |
|Interne servers       |42 |2001:db8:ac03:42::  |2001:db8:ac03:42::1<br>2001:db8:ac03:42::FFFF    |/64        |
|ISP-Interfaces        |N/A|2001:db8:ac03:FFFF::|2001:db8:ac03:FFFF::1<br>2001:db8:ac03:FFFF::FFFF|/64        |
### Addressing
|Device                |Interface|VLAN|IPv6-address            |Subnet|Default Gateway                                                  |
|:---------------------|--------:|:---|:----------------------:|:----:|:---------------------------------------------------------------:|
|ISP Router            |G0/0     |N/A |2001:db8:ac03:FFFF::FFFF|/64   |N/A                                                              |
|Router 1              |G0/0     |N/A |2001:db8:ac03:FFFF::FFFD|/64   |N/A                                                              |
|                      |G0/1.1   |1   |2001:db8:ac03:1::FFFE   |/64   |N/A                                                              |
|                      |G0/1.11  |11  |2001:db8:ac03:11::FFFE  |/64   |N/A                                                              |
|                      |G0/1.13  |13  |2001:db8:ac03:13::FFFE  |/64   |N/A                                                              |
|                      |G0/1.42  |42  |2001:db8:ac03:42::FFFE  |/64   |N/A                                                              |
|Router 1 (BackUp)     |G0/0     |N/A |2001:db8:ac03:FFFF::FFFC|/64   |N/A                                                              |
|                      |G0/1.1   |1   |2001:db8:ac03:1::FFFD   |/64   |N/A                                                              |
|                      |G0/1.11  |11  |2001:db8:ac03:11::FFFD  |/64   |N/A                                                              |
|                      |G0/1.13  |13  |2001:db8:ac03:13::FFFD  |/64   |N/A                                                              |
|                      |G0/1.42  |42  |2001:db8:ac03:42::FFFD  |/64   |N/A                                                              |
|Virtuele router (HSRP)|G0/0     |N/A |2001:db8:ac03:FFFF::FFFE|/64   |N/A                                                              |
|                      |VLAN 1   |1   |2001:db8:ac03:1::FFFF   |/64   |N/A                                                              |
|                      |VLAN 11  |11  |2001:db8:ac03:11::FFFF  |/64   |N/A                                                              |
|                      |VLAN 13  |13  |2001:db8:ac03:13::FFFF  |/64   |N/A                                                              |
|                      |VLAN 42  |42  |2001:db8:ac03:42::FFFF  |/64   |N/A                                                              |
|Switch 1              |VLAN 1   |1   |2001:db8:ac03:1::FFFC   |/64   |2001:db8:ac03:1::FFFF (HSRP)<br>2001:db8:ac03:1::FFFE (NO HSRP)  |
|TFTP Server           |Fa0      |1   |2001:db8:ac03:1::FFFB   |/64   |2001:db8:ac03:1::FFFF (HSRP)<br>2001:db8:ac03:1::FFFE (NO HSRP)  |
|Proxy Server          |Fa0      |13  |2001:db8:ac03:13::FFFC  |/64   |2001:db8:ac03:13::FFFF (HSRP)<br>2001:db8:ac03:13::FFFE (NO HSRP)|
|CA Server             |Fa0      |13  |2001:db8:ac03:13::FFFB  |/64   |2001:db8:ac03:13::FFFF (HSRP)<br>2001:db8:ac03:13::FFFE (NO HSRP)|
|LinuxCLI (DB)         |Fa0      |42  |2001:db8:ac03:42::FFFC  |/64   |2001:db8:ac03:42::FFFF (HSRP)<br>2001:db8:ac03:42::FFFE (NO HSRP)|
|LinuxCLI (Web)        |Fa0      |42  |2001:db8:ac03:42::FFFB  |/64   |2001:db8:ac03:42::FFFF (HSRP)<br>2001:db8:ac03:42::FFFE (NO HSRP)|
|WinServ (DC)          |Fa0      |42  |2001:db8:ac03:42::FFFA  |/64   |2001:db8:ac03:42::FFFF (HSRP)<br>2001:db8:ac03:42::FFFE (NO HSRP)|
|LinuxCLI (matrix.org) |Fa0      |42  |2001:db8:ac03:42::FFF9  |/64   |2001:db8:ac03:42::FFFF (HSRP)<br>2001:db8:ac03:42::FFFE (NO HSRP)|
|LinuxCLI (Nextcloud)  |Fa0      |42  |2001:db8:ac03:42::FFF8  |/64   |2001:db8:ac03:42::FFFF (HSRP)<br>2001:db8:ac03:42::FFFE (NO HSRP)|
|LinuxCLI (Web-BackUp) |Fa0      |42  |2001:db8:ac03:42::FFF7  |/64   |2001:db8:ac03:42::FFFF (HSRP)<br>2001:db8:ac03:42::FFFE (NO HSRP)|

