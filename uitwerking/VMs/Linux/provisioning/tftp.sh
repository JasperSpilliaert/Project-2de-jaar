#! /bin/bash
#
# Provisioning script for srv001

#------------------------------------------------------------------------------
# Bash settings
#------------------------------------------------------------------------------

# Enable "Bash strict mode"
set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't mask errors in piped commands

#------------------------------------------------------------------------------
# Variables
#------------------------------------------------------------------------------

# Location of provisioning scripts and files
readonly PROVISIONING_SCRIPTS="/vagrant/provisioning/"
# Location of files to be copied to this server
readonly PROVISIONING_FILES="${PROVISIONING_SCRIPTS}/files/${HOSTNAME}"
# Variabelen voor belangrijke gegevens
readonly TFTP_DIRECTORY="/vagrant/netwerk-config/configFiles"


#------------------------------------------------------------------------------
# "Imports"
#------------------------------------------------------------------------------

# Actions/settings common to all servers
source ${PROVISIONING_SCRIPTS}/common.sh



#------------------------------------------------------------------------------
# Provision server
#------------------------------------------------------------------------------

log "=== Starten van server-specifieke provisioning-taken op ${HOSTNAME} ==="

sudo echo -e "IPV6INIT=yes\nIPV6_AUTOCONF=no\nIPV6ADDR=2001:db8:ac03:1::FFFB/64\nIPV6_DEFAULTGW=2001:db8:ac03:1::FFFF" >> /etc/sysconfig/network-scripts/ifcfg-eth1

sudo systemctl restart NetworkManager

# installatie en config tftp-server
if ! dnf list installed vsftpd &> /dev/null; then
    log "tftpd-server installeren"
    dnf install -y tftp-server
else
    log "tftpd-server is al geïnstalleerd"
fi


log "Configuring TFTP server in ${TFTP_DIRECTORY}"
mkdir -p ${TFTP_DIRECTORY}
getent group tftp > /dev/null 2>&1 ||  groupadd tftp
id tftpuser > /dev/null 2>&1 ||  adduser tftpuser
 usermod -aG tftp tftpuser


# instellen folder config 
tee /usr/lib/systemd/system/tftp.service<<EOF
[Unit]
Description=Tftp Server
Requires=tftp.socket
Documentation=man:in.tftpd

[Service]
ExecStart=/usr/sbin/in.tftpd  -c -p -s ${TFTP_DIRECTORY} -v -u tftpuser
StandardInput=socket
Group=tftp
[Install]
WantedBy=multi-user.target
Also=tftp.socket
EOF

# geef alle rechten aan tftp
log "chown -R tftpuser:tftp ${TFTP_DIRECTORY}"
chown -R tftpuser:tftp ${TFTP_DIRECTORY}
chmod -R g+rwx ${TFTP_DIRECTORY}




#Firewall instellen
log "Firewall controleren voor TFTP"
ip link set dev "$INTERFACE" down && ip link set dev "$INTERFACE" up
if !  firewall-cmd --permanent --zone=public --query-rich-rule 'rule family="ipv4" source address="'${NETWORK_VLAN1}/${NETMASK_VLAN1}'" service name="tftp" accept' &> /dev/null; then
     firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" source address="'${NETWORK_VLAN1}/${NETMASK_VLAN1}'" service name="tftp" accept'
     log "Firewallregel voor TFTP toegevoegd"
fi
log "Firewallregels herladen"
firewall-cmd --reload
log "Firewallregels herladen"
systemctl daemon-reload   
systemctl restart tftp



log "TFTP server geconfigureerd in ${TFTP_DIRECTORY}"
# check of tftp service actief is
if !  systemctl is-active --quiet tftp; then
    log "tftp service starten"
     systemctl start tftp
fi
# check of tftp service actief is bij opstarten
if !  systemctl is-enabled --quiet tftp; then
    log "tftp service activeren"
    systemctl enable  tftp
    log "tftp service is geactiveerd en actief"
fi

log "SELinux context instellen voor TFTP"
# check voor correcte SELinux context
if ! echo $(sudo semanage fcontext --list) | grep -q "${TFTP_DIRECTORY}(/.*)?"; then
    # Als de context nog niet bestaat, voeg het dan toe
    sudo semanage fcontext -a -t public_content_rw_t "${TFTP_DIRECTORY}(/.*)?"
    setsebool -P tftp_anon_write 1
    setsebool -P tftp_home_dir 1
    log "SELinux context toegevoegd."
else
    log "SELinux context bestaat al, geen actie ondernomen."
fi
restorecon -Rv ${TFTP_DIRECTORY}

sudo ip route del default via 10.0.2.2 dev eth0
sudo ip route del 192.168.103.128/28 dev eth1

log "Provisioning complete"

