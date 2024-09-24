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
# tftp location
readonly TFTP_DIRECTORY="/etc/tftp/sharedfolder"

#certificate passphrase
readonly passphrase="Appeltaart1"
#------------------------------------------------------------------------------
# Functions
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Provision server
#------------------------------------------------------------------------------
# First perform common actions for all servers
source ${PROVISIONING_SCRIPTS}/common.sh


#disable root login and password login
sudo sed -i -e 's/^#PermitRootLogin yes/PermitRootLogin no/' -e 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo echo -e "IPV6INIT=yes\nIPV6_AUTOCONF=no\nIPV6ADDR=2001:db8:ac03:13::FFFB/64\nIPV6_DEFAULTGW=2001:db8:ac03:13::FFFF" >> /etc/sysconfig/network-scripts/ifcfg-eth1
log "File aangevuld"
sudo systemctl restart NetworkManager
log "Restart NM"

#Install openssl
sudo dnf install openssl -y

sudo ip route del default via 10.0.2.2 dev eth0
log "default route"
sudo ip route del 192.168.103.144/28 dev eth1
log "route"

mkdir /home/vagrant/certs
mkdir /home/vagrant/certs/ca
cd /home/vagrant/certs/ca

#generate private key local CA
openssl genrsa -des3 -passout "pass:$passphrase" -out myCA.key 2048

# make unencrypted file
#openssl rsa -in myCA.key -out myCA.key.unencrypted

#Generate root certificate
openssl req -x509 -new -nodes -key myCA.key -sha256 -days 1825 -out myCA.pem\
    -passin "pass:$passphrase"\
    -subj "/C=BE/ST=OV/L=Ghent/O=Hogent/CN=g03-fft.internal"

#certificate packages
sudo dnf install -y ca-certificates

#adding the root certificate
cp myCA.pem /etc/pki/ca-trust/source/anchors/myCA.crt
sudo update-ca-trust

cd /home/vagrant/certs
mkdir g03-fft.internal
cd g03-fft.internal

#creating key for website
openssl genrsa -out g03-fft.internal.key 2048
openssl req -new -key g03-fft.internal.key -out g03-fft.internal.csr \
    -subj "/C=BE/ST=OV/L=Ghent/O=Hogent/CN=g03-fft.internal" \
    -reqexts SAN -config <(cat /etc/ssl/openssl.cnf <(printf "[SAN]\nsubjectAltName=DNS:g03-fft.internal,DNS:www.g03-fft.internal,DNS:extra.g03-fft.internal,DNS:nextcloud.g03-fft.internal,DNS:matrix.g03-fft.internal"))

#creating key for extra website
#cd ..
#mkdir extra.g03-fft.internal
#cd extra.g03-fft.internal
#openssl genrsa -out extra.g03-fft.internal.key 2048
#openssl req -new -key extra.g03-fft.internal.key -out extra.g03-fft.internal.csr \
#    -subj "/C=BE/ST=OV/L=Ghent/O=Hogent/CN=extra.g03-fft.internal"

#ext file voor aanmaken cert
touch g03-fft.internal.ext
cat > g03-fft.internal.ext << EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = g03-fft.internal
DNS.2 = www.g03-fft.internal
DNS.3 = extra.g03-fft.internal
DNS.4 = nextcloud.g03-fft.internal
DNS.5 = matrix.g03-fft.internal
EOF

echo kaas

#aanmaken certificate extra
#openssl x509 -req -in extra.g03-fft.internal.csr -CA /home/vagrant/certs/ca/myCA.pem -CAkey /home/vagrant/certs/ca/myCA.key -CAcreateserial \
#-out extra.g03-fft.internal.crt -days 825 -sha256 -extfile g03-fft.internal.ext\
#    -passin "pass:$passphrase"

#sudo cp g03-fft.internal.ext ../g03-fft.internal
#cd ../g03-fft.internal

#aanmaken certificate
openssl x509 -req -in g03-fft.internal.csr -CA /home/vagrant/certs/ca/myCA.pem -CAkey /home/vagrant/certs/ca/myCA.key -CAcreateserial \
-out g03-fft.internal.crt -days 825 -sha256 -extfile g03-fft.internal.ext\
    -passin "pass:$passphrase"

# overzetten files met tftp
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




# Firewall instellen
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

# Disable ssh password login and root login
sudo sed -i -e 's/^#PermitRootLogin yes/PermitRootLogin no/' -e 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

log "Provisioning complete"