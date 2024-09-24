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
headers_config="/headers/headers-more-nginx-module"
config_file="/etc/nginx/conf.d/g03-fft.internal.conf"
config_file_extra="/etc/nginx/conf.d/extra.g03-fft.internal.conf"
config_file_nextcloud="/etc/nginx/conf.d/nextcloud.g03-fft.internal.conf"
config_file_matrix="/etc/nginx/conf.d/matrix.g03-fft.internal.conf"
cert_path="/etc/ssl/certs/myCertificate.crt"
key_path="/etc/ssl/certs/myKey.key"
webserver_ip="192.168.103.186"
redundant_webserver_ip="192.168.103.182"
# Location of provisioning scripts and files
readonly PROVISIONING_SCRIPTS="/vagrant/provisioning/"
# Location of files to be copied to this server
readonly PROVISIONING_FILES="${PROVISIONING_SCRIPTS}/files/${HOSTNAME}"

#------------------------------------------------------------------------------
# Functions
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Provision server
#------------------------------------------------------------------------------

#common script import
source ${PROVISIONING_SCRIPTS}/common.sh


sudo echo -e "IPV6INIT=yes\nIPV6_AUTOCONF=no\nIPV6ADDR=2001:db8:ac03:13::FFFC/64\nIPV6_DEFAULTGW=2001:db8:ac03:13::FFFF" >> /etc/sysconfig/network-scripts/ifcfg-eth1

sudo systemctl restart NetworkManager

# Disable ssh password login and root login
sudo sed -i -e 's/^#PermitRootLogin yes/PermitRootLogin no/' -e 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# Install nginx

log "=== Starting server specific provisioning tasks on ${HOSTNAME} ==="

log "Installing nginx reverse proxy"

#C compiler voor download
sudo dnf install gcc pcre-devel zlib-devel openssl-devel -y

#nginx compilen met module file
 wget 'http://nginx.org/download/nginx-1.21.4.tar.gz'
 tar -xzvf nginx-1.21.4.tar.gz
 cd nginx-1.21.4/

 #adding module
 wget https://github.com/openresty/headers-more-nginx-module/archive/refs/tags/v0.37.tar.gz
 tar -xzvf v0.37.tar.gz

 #moving to source dir
 mkdir -p /nginx-1.21.4/src/http/modules
 mv headers-more-nginx-module-0.37 /nginx-1.21.4/src/http/modules/
 ./configure --prefix=/etc/nginx --add-module=/nginx-1.21.4/src/http/modules/headers-more-nginx-module-0.37 --with-http_ssl_module --with-http_v2_module

 make
 sudo make install

#making service
 cat <<EOF > "/etc/systemd/system/nginx.service"
 [Unit]
Description=nginx - high performance web server
After=network.target

[Service]
Type=forking
ExecStart=/etc/nginx/sbin/nginx
ExecReload=/etc/nginx/sbin/nginx -s reload
ExecStop=/etc/nginx/sbin/nginx -s stop
PIDFile=/etc/nginx/logs/nginx.pid
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload

# Firewall

log "Setting firewall rules"
 
sudo firewall-cmd --zone=public --add-port=80/tcp --permanent
sudo firewall-cmd --zone=public --add-port=443/tcp --permanent

sudo firewall-cmd --reload

#Tls keys

log "Aanmaken tls keys"

sudo mkdir -p /etc/ssl/certs
chmod 700 /etc/ssl/certs

sudo openssl req -new -newkey rsa:4096 -x509 -sha256 -days 365 -nodes -keyout "$key_path" -out  "$cert_path" \
    -subj "/C=BE/ST=OV/L=Ghent/O=Hogent/CN=g03-fft.internal"

sudo chmod 600 /etc/ssl/certs/myKey.key /etc/ssl/certs/myCertificate.crt


# Prevent nmap from giving information
#sed -i '/http {/a \    server_tokens off;' /etc/nginx/nginx.conf

log "Enabling nginx service"
sudo systemctl start nginx

systemctl enable --now nginx

log "Starting nginx config"

sudo mkdir /etc/nginx/certs
sudo mkdir /etc/nginx/conf.d

#making nginx config file
sudo touch /access.log
sudo rm /etc/nginx/conf/nginx.conf -f
cat <<EOF > "/etc/nginx/conf/nginx.conf"
worker_processes auto;
# pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
    worker_connections 2048;
    use epoll;  # Efficient handling of connections on Linux
}

http {
    include       mime.types;
    default_type  application/octet-stream;

    log_format main '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                    '\$status \$body_bytes_sent "\$http_referer" '
                    '"\$http_user_agent" "\$http_x_forwarded_for"';

    # access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   20s;
    types_hash_max_size 2048;
    server_tokens       off;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_ciphers 'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256';
    ssl_session_cache shared:SSL:10m;
    ssl_session_tickets off;
    ssl_stapling on;
    ssl_stapling_verify on;
    resolver 8.8.8.8 valid=300s;  # External resolver for OCSP stapling

    # Custom server header for security through obscurity
    more_set_headers 'Server: Apache';

    # Rate limiting setup
    limit_req_zone \$binary_remote_addr zone=one:10m rate=5r/s;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
    #add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval' https://trustedscripts.example.com;";
    
    #access_log /access.log;
    include /etc/nginx/conf.d/*.conf;  # Include all external server blocks

}
EOF
#Configure nginx to listen on port 80 and 443 and proxy requests for g03-syndus.internal to 192.168.103.19
cat <<EOF > "$config_file"
upstream backend{
    server $webserver_ip;
    server $redundant_webserver_ip;
    # server [2001:db8:ac03:42::FFFB];
    # server [2001:db8:ac03:42::FFF7];
}
server {
    listen 80;
    listen [::]:80;
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name g03-fft.internal www.g03-fft.internal;

    if (\$scheme != "https") {
        return 301 https://\$host\$request_uri;
    }

    ssl_certificate /etc/ssl/certs/myCertificate.crt;
    ssl_certificate_key /etc/ssl/certs/myKey.key;
    ssl_client_certificate /etc/nginx/certs/myCA.crt;

    # Error Handling
    error_page 502 503 504 /custom_50x.html;
    location = /custom_50x.html {
    root /usr/share/nginx/html;
    internal;
    }

    location / {
        proxy_pass http://backend;
        proxy_redirect off;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header Host \$http_host;
    }
}
EOF

# Extra website
cat <<EOF > "$config_file_extra"
upstream backend2{
    server $webserver_ip;
    server $redundant_webserver_ip;
    # server [2001:db8:ac03:42::FFFB];
    # server [2001:db8:ac03:42::FFF7];
}
server {
    listen 80;
    listen [::]:80;
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name extra.g03-fft.internal;

    if (\$scheme != "https") {
        return 301 https://\$host\$request_uri;
    }

    ssl_certificate /etc/ssl/certs/myCertificate.crt;
    ssl_certificate_key /etc/ssl/certs/myKey.key;
    ssl_client_certificate /etc/nginx/certs/myCA.crt;

    # Error Handling
    error_page 502 503 504 /custom_50x.html;
    location = /custom_50x.html {
    root /usr/share/nginx/html;
    internal;
    }

    location / {
        proxy_pass http://backend2;
        proxy_redirect off;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header Host \$http_host;

    }
}
EOF

# Nextcloud server block
cat <<EOF > "$config_file_nextcloud"
server {
    listen 80;
    listen [::]:80;
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name nextcloud.g03-fft.internal;

    if (\$scheme != "https") {
        return 301 https://\$host\$request_uri;
    }

    ssl_certificate /etc/ssl/certs/myCertificate.crt;
    ssl_certificate_key /etc/ssl/certs/myKey.key;
    ssl_client_certificate /etc/nginx/certs/myCA.crt;

    # Error Handling
    error_page 502 503 504 /custom_50x.html;
    location = /custom_50x.html {
    root /usr/share/nginx/html;
    internal;
    }

    location / {
        proxy_pass http://192.168.103.183;
        #proxy_pass http://[2001:db8:ac03:42::FFF8];
        proxy_redirect off;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header Host \$http_host;
    }
}
EOF

# Matrix server block
cat <<EOF > "$config_file_matrix"
server {
    listen 80;
    listen [::]:80;
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name matrix.g03-fft.internal;

    if (\$scheme != "https") {
        return 301 https://\$host\$request_uri;
    }

    ssl_certificate /etc/ssl/certs/myCertificate.crt;
    ssl_certificate_key /etc/ssl/certs/myKey.key;
    ssl_client_certificate /etc/nginx/certs/myCA.crt;

    # Error Handling
    error_page 502 503 504 /custom_50x.html;
    location = /custom_50x.html {
    root /usr/share/nginx/html;
    internal;
    }

    location / {
        proxy_pass http://192.168.103.184;
        #proxy_pass http://[2001:db8:ac03:42::FFF9];
        proxy_redirect off;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header Host \$http_host;
    }
}
EOF
sudo systemctl restart nginx

#TEST (delete)
#echo "192.168.103.155 g03-fft.internal" >> /etc/hosts
echo "192.168.103.155 www.g03-fft.internal" >> /etc/hosts
echo "2001:db8:ac03:13::FFFC g03-fft.internal" >> /etc/hosts

#Configuring SELinux nginx policies
log "Configuring SELinux"
#putting an entry in the logs 
curl -k https://g03-fft.internal
sudo cat /var/log/audit/audit.log | grep nginx | audit2allow -m nginx_custom > nginx_custom.te
sudo checkmodule -M -m -o nginx_custom.mod nginx_custom.te
sudo semodule_package -o nginx_custom.pp -m nginx_custom.mod
sudo semodule -i nginx_custom.pp

#restarts
#sudo systemctl restart httpd
sudo systemctl restart nginx

log "nginx configuratie voltooid"

sudo ip route del default via 10.0.2.2 dev eth0
sudo ip route del 192.168.103.144/28 dev eth1

log "Provisioning complete"


