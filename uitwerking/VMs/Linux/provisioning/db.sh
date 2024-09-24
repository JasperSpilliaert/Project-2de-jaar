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

# Database root password
readonly db_root_password='IcAgWaict9?slamrol'

# Database name
readonly db_name=trialsite

# Database table
readonly db_table=trialsite_tbl

# Database user
readonly db_user=www_user

# Database password
readonly db_password='Kof3Cup.ByRu'

# IP address of the web server
readonly web_server_ip=192.168.103.186 # Change this to the actual IP address of your web server

#------------------------------------------------------------------------------
# Functions
#------------------------------------------------------------------------------

# Predicate that returns exit status 0 if the database root password
# is not set, a nonzero exit status otherwise.
is_mysql_root_password_empty() {
  mysqladmin --user=root status > /dev/null 2>&1
}

#------------------------------------------------------------------------------
# Provision server
#------------------------------------------------------------------------------
cd /etc/ssh/ && sed -i 's/^#PermitRootLogin/PermitRootLogin/' sshd_config

#IPv6 instellen
sudo echo -e "IPV6INIT=yes\nIPV6_AUTOCONF=no\nIPV6ADDR=2001:db8:ac03:42::FFFC/64\nIPV6_DEFAULTGW=2001:db8:ac03:42::FFFF" >> /etc/sysconfig/network-scripts/ifcfg-eth1

sudo systemctl restart NetworkManager

# First perform common actions for all servers
source ${PROVISIONING_SCRIPTS}/common.sh

log "=== Starting server specific provisioning tasks on ${HOSTNAME} ==="

log "Installing MariaDB server"

dnf install -y mariadb-server 

log "Enabling MariaDB service"

systemctl enable --now mariadb.service

log "Setting firewall rules"

# Open SSH and database ports
firewall-cmd --add-service=ssh --permanent
firewall-cmd --add-service=mysql --permanent

# Restrict MySQL to only allow connections from the web server IP
firewall-cmd --add-rich-rule='rule family="ipv4" source address='$STATIC_IP_WEB' port protocol="tcp" port="3306" accept' --permanent

# Reload firewall
firewall-cmd --reload

log "Securing the database"

if is_mysql_root_password_empty; then
mysql <<_EOF_
  SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${db_root_password}');
  DELETE FROM mysql.user WHERE User='';
  DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
  DROP DATABASE IF EXISTS test;
  DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
  FLUSH PRIVILEGES;
_EOF_
fi

log "Creating database and user"

mysql --user=root --password="${db_root_password}" << _EOF_
CREATE DATABASE IF NOT EXISTS ${db_name};
GRANT ALL ON ${db_name}.* TO '${db_user}'@'%' IDENTIFIED BY '${db_password}';
FLUSH PRIVILEGES;
_EOF_

log "Creating database table and add some data"

mysql --user="${db_user}" --password="${db_password}" "${db_name}" <<_EOF_
CREATE TABLE IF NOT EXISTS ${db_table} (
  id int(5) NOT NULL AUTO_INCREMENT,
  name varchar(50) DEFAULT NULL,
  PRIMARY KEY(id)
);
REPLACE INTO ${db_table} (id,name) VALUES (1,"Tuxedo T. Penguin");
REPLACE INTO ${db_table} (id,name) VALUES (2,"Bobby Tables");
_EOF_

sudo ip route del default via 10.0.2.2 dev eth0
sudo ip route del 192.168.103.160/27 dev eth1

log "Provisioning complete"
