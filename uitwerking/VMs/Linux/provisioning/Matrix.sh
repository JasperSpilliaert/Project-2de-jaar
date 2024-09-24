#! /bin/bash
#
# Provisioning script for Synapse Matrix

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

readonly PROVISIONING_SCRIPTS="/vagrant/provisioning/" 

SERVER_NAME="matrix.g03-fft.internal"
SYNAPSE_DIR="/home/vagrant/synapse"
NGINX_CONF_DIR="/etc/nginx/conf.d/"
SYSTEMD_DIR="/etc/systemd/system/"
cert_path="/etc/ssl/certs/myCertificate.crt"
key_path="/etc/ssl/certs/myKey.key"

#------------------------------------------------------------------------------
# Provision server
#------------------------------------------------------------------------------

#common script import

source ${PROVISIONING_SCRIPTS}/common.sh

sudo setenforce 0 # om toch users.sh te laten werken -> doet het nu toch niet meer?

sudo echo -e "IPV6INIT=yes\nIPV6_AUTOCONF=no\nIPV6ADDR=2001:db8:ac03:42::FFF9/64\nIPV6_DEFAULTGW=2001:db8:ac03:42::FFFF" >> /etc/sysconfig/network-scripts/ifcfg-eth1

sudo systemctl restart NetworkManager

# Stap 1: Dependencies installeren

# Ensure all packages are up to date
sudo dnf update -y

echo "Installing necessary packages" 

sudo dnf install -y epel-release
sudo dnf install -y jq python3 python3-pip git nginx firewalld sqlite

echo "Installing Node.js -> (needed for Discord bridge)" 

curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -
sudo dnf install -y nodejs

# Stap 2: Python environment opzetten

echo "setting up python environment for synapse" 

python3 -m venv $SYNAPSE_DIR
source $SYNAPSE_DIR/bin/activate
pip install --upgrade pip
pip install matrix-synapse

echo "Generating Synapse configuration" 

cd $SYNAPSE_DIR
python -m synapse.app.homeserver \
    --server-name $SERVER_NAME \
    --config-path homeserver.yaml \
    --generate-config \
    --report-stats=no

# Stap 3: Adjusting the configuration to enable registration

echo "Adjusting the configuration to enable registration"

sed -i 's/#enable_registration: false/enable_registration: true/' homeserver.yaml

# Stap 4: Firewall configuration

echo "Configure firewall" # wordt denk ik al gedaan in common.sh

sudo systemctl start firewalld
sudo firewall-cmd --add-service={ssh,http,https} --permanent
sudo firewall-cmd --add-port=8008/tcp --permanent
sudo firewall-cmd --add-port=8448/tcp --permanent
sudo firewall-cmd --add-port=29334/tcp --permanent  # voor discord bridge
sudo firewall-cmd --reload

# Stap 5: Nginx configuration

echo "Configuring nginx" 
sudo cp /vagrant/Scripts_FilesMatrix/nginx.conf $NGINX_CONF_DIR
cd $SYNAPSE_DIR
echo "done"

echo "SSL certs"
sudo mkdir -p /etc/ssl/certs
chmod 700 /etc/ssl/certs
sudo openssl req -new -newkey rsa:4096 -x509 -sha256 -days 365 -nodes -keyout "$key_path" -out  "$cert_path" \
	-subj "/C=BE/ST=OV/L=Ghent/O=Hogent/CN=matrix.g03-fft.internal"
sudo chmod 600 /etc/ssl/certs/myKey.key /etc/ssl/certs/myCertificate.crt

echo "127.0.0.1 matrix.g03-fft.internal" >> /etc/hosts
echo "192.168.103.184 www.matrix.g03-fft.internal" >> /etc/hosts

echo "nginx heropstarten"
sudo systemctl restart nginx
sudo systemctl enable nginx

# Stap 6: Configuring systemd service for Synapse

echo "Configuring systemd service for Synapse" 

sudo mkdir -p /etc/synapse

sudo cp $SYNAPSE_DIR/homeserver.yaml /etc/synapse/
sudo cp /vagrant/Scripts_FilesMatrix/synapse.service $SYSTEMD_DIR
sudo systemctl daemon-reload
sudo systemctl enable synapse
sudo systemctl start synapse

echo "Waiting for Synapse to initialize..."
sleep 3

# Stap 7: Users creëren

echo "user configuration" 

bash /vagrant/Scripts_FilesMatrix/users.sh 

# Stap 8: installeren Element Client -> niet meer nodig, want geen GUI
# echo "Installing Element Client"

# sudo dnf install flatpak -y
# sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
# sudo flatpak install flathub im.riot.Riot -y

# Stap 9: room creëren

echo "Creating room"

bash /vagrant/Scripts_FilesMatrix/room.sh 

# Stap 10: Configuratie van de Systemd Service

echo "creating message system"

sudo cp /vagrant/Scripts_FilesMatrix/send_matrix_message.sh /usr/local/bin/ 
sudo chmod +x /usr/local/bin/send_matrix_message.sh

sudo cp /vagrant/Scripts_FilesMatrix/matrix_message_on_shutdown.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable matrix_message_on_shutdown.service
sudo systemctl start matrix_message_on_shutdown.service

# Stap 11: bridge naar discord setup

echo "bridge naar discord setup" 

bash /vagrant/Scripts_FilesMatrix/discord.sh

echo "Matrix server setup complete!"

# Stap 12: GUI maken -> eruit, want moet op Windows Client VM
# echo "making GUI for Almalinux VM" # -> werkt, maar voorlopig nog error bij het rebooten van synapse 
# bash /vagrant/Scripts_FilesMatrix/gui.sh

sudo setenforce 0
sudo systemctl restart synapse
sudo systemctl daemon-reload
sudo systemctl restart synapse

log "Provisioning complete"

sudo ip route del default via 10.0.2.2 dev eth0
sudo ip route del 192.168.103.160/27 dev eth1