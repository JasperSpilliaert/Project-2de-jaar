#! /bin/bash
#

# based on https://orcacore.com/install-configure-nextcloud-almalinux-9/

# Provisioning script for installing Nextcloud on AlmaLinux

#------------------------------------------------------------------------------
# Bash settings
#------------------------------------------------------------------------------

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

# Database connection details
readonly db_host='192.168.103.183'

# Nextcloud variables
readonly NEXTCLOUD_VERSION="latest"
readonly NEXTCLOUD_DIR="/var/www/html/nextcloud"
readonly NEXTCLOUD_DB_NAME="nextcloud"
readonly NEXTCLOUD_DB_USER="nextcloud"
readonly NEXTCLOUD_DB_PASSWORD="yourpassword"


#------------------------------------------------------------------------------
# Provisioning tasks
#------------------------------------------------------------------------------


# Download and install Nextcloud

#Disable SELinux on AlmaLinux 9
sudo setenforce 0
sudo sed -i 's/^SELINUX=.*/SELINUX=permissive/g' /etc/selinux/config
sestatus

sudo echo -e "IPV6INIT=yes\nIPV6_AUTOCONF=no\nIPV6ADDR=2001:db8:ac03:42::FFF8/64\nIPV6_DEFAULTGW=2001:db8:ac03:42::FFFF" >> /etc/sysconfig/network-scripts/ifcfg-eth1

sudo systemctl restart NetworkManager

#Install Additional PHP Extensions for Nextcloud
sudo dnf update -y

sudo dnf -y install php php-curl php-bcmath php-gd php-soap php-zip php-curl php-mbstring php-mysqlnd php-gd php-xml php-intl php-zip unzip httpd mariadb-server mariadb php-cli php-mysqlnd php-zip php-devel php-gd php-mbstring php-curl php-xml php-pear php-bcmath php-json php-pdo php-pecl-apcu php-pecl-apcu-devel php-ldap

#Services opzetten

sudo systemctl enable --now httpd

sudo systemctl start firewalld
sudo systemctl enable firewalld

sudo firewall-cmd --add-service=http --permanent
sudo firewall-cmd --reload

sudo systemctl enable --now mariadb

sudo php -v

sudo sed -i 's/memory_limit = .*/memory_limit = 512M/' /etc/php.ini

#Create a Nextcloud Database on AlmaLinux 9

sudo mysql -u root -p <<EOF
CREATE USER 'nextcloud-user'@'localhost' IDENTIFIED BY 'password';
CREATE DATABASE nextclouddb;
GRANT ALL PRIVILEGES ON nextclouddb.* TO 'nextcloud-user'@'localhost';
FLUSH PRIVILEGES;
exit
EOF

#Set up Nextcloud on AlmaLinux 9

sudo wget https://download.nextcloud.com/server/releases/latest.zip
sudo unzip latest.zip
sudo mv nextcloud/ /var/www/html/
sudo mkdir /var/www/html/nextcloud/data
sudo chown apache:apache -R /var/www/html/nextcloud

# Enable and install Calendar app
#sudo -u apache php /var/www/html/nextcloud/occ app:enable calendar
#sudo -u apache php /var/www/html/nextcloud/occ app:install calendar

# Enable and install Forms app
#sudo -u apache php /var/www/html/nextcloud/occ app:enable forms
#sudo -u apache php /var/www/html/nextcloud/occ app:install forms

sudo systemctl restart httpd
sudo firewall-cmd --add-service={http,https} --permanent
sudo firewall-cmd --reload

sudo ip route del default via 10.0.2.2 dev eth0
sudo ip route del 192.168.103.160/27 dev eth1

cd /var/www/html/nextcloud
sudo -u apache php occ config:system:set trusted_domains 1 --value="${nextcloud.g03-fft.internal/nextcloud}"

echo "Provisioning complete"