#! /bin/bash
#
# Provisioning script for srv001

# web ip = 192.168.103.184/27
# web DG = 192.168.103.190

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

# Database connection details
readonly db_host='192.168.103.187'
readonly db_user='www_user'
readonly db_password='Kof3Cup.ByRu'
readonly db_name='trialsite'
readonly db_table='trialsite_tbl'

# CMS configuration
readonly CMS="wordpress"  # Choose your CMS (e.g., wordpress, drupal, etc.)

# WordPress configuration
readonly WORDPRESS_VERSION="5.9"  # Update to the latest version
readonly WORDPRESS_URL="https://wordpress.org/wordpress-${WORDPRESS_VERSION}.tar.gz"
readonly WORDPRESS_DIR="/var/www/html/wordpress"
#------------------------------------------------------------------------------
# "Imports"
#------------------------------------------------------------------------------

# Actions/settings common to all servers
source ${PROVISIONING_SCRIPTS}/common.sh

#------------------------------------------------------------------------------
# Provision server
#------------------------------------------------------------------------------
cd /etc/ssh/ && sed -i 's/^#PermitRootLogin/PermitRootLogin/' sshd_config

sudo echo -e "IPV6INIT=yes\nIPV6_AUTOCONF=no\nIPV6ADDR=2001:db8:ac03:42::FFFB/64\nIPV6_DEFAULTGW=2001:db8:ac03:42::FFFF" >> /etc/sysconfig/network-scripts/ifcfg-eth1

sudo systemctl restart NetworkManager

log "Starting server specific provisioning tasks on ${HOSTNAME}"

# TODO: insert code here, e.g. install Apache, add users, etc.
#Install and launch Neofetch
log "Installing an initialising Neofetch"
dnf install -y epel-release

#Install and start Apache web server
log "Installing Apache server"
dnf install -y httpd

log "Enabeling and starting Apache server"
systemctl start httpd
systemctl enable httpd

#Allow incoming traffic (http en https)
log "Allowing traffic on port 80 (HTTP)"
firewall-cmd --zone=public --add-port=80/tcp
firewall-cmd --zone=public --add-port=80/tcp --permanent
log "Allowing traffic on port 443 (HTTPS)"
firewall-cmd --zone=public --add-port=443/tcp
firewall-cmd --zone=public --add-port=443/tcp --permanent

#Installing PHP for database connection
log "Installing PHP to run PHP scripts"
dnf install -y php php-mysqli php-mysqlnd php-json php-gd php-xml php-mbstring

#Allowing traffic between Apache and DB server
log "HTTP can network connect DB"
setsebool httpd_can_network_connect_db on
setsebool -P httpd_can_network_connect_db on
	
#Restarting Web server to save changes
log "Restarting web server"
systemctl restart httpd

# Download and install CMS
log "Downloading and installing ${CMS}"
mkdir -p "${WORDPRESS_DIR}"
curl -o /tmp/wordpress.tar.gz "${WORDPRESS_URL}"
tar -xzf /tmp/wordpress.tar.gz -C "${WORDPRESS_DIR}" --strip-components=1
chown -R apache:apache "${WORDPRESS_DIR}"
chmod -R 755 "${WORDPRESS_DIR}"

# Configure WordPress to use the database
log "Configuring WordPress to use the database"
cp "${WORDPRESS_DIR}/wp-config-sample.php" "${WORDPRESS_DIR}/wp-config.php"
sed -i "s/database_name_here/${db_name}/" "${WORDPRESS_DIR}/wp-config.php"
sed -i "s/username_here/${db_user}/" "${WORDPRESS_DIR}/wp-config.php"
sed -i "s/password_here/${db_password}/" "${WORDPRESS_DIR}/wp-config.php"
sed -i "s/localhost/${db_host}/" "${WORDPRESS_DIR}/wp-config.php"

#Restarting Web server to save changes
log "Restarting web server"
systemctl restart httpd

#Creating index.html page
log "Creating index page"
touch /var/www/html/index.html
cp /vagrant/logo.png /var/www/html/logo.png
cat << 'EOF' >/var/www/html/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FFT - Future Flow Tech</title>
    <style>
        /* Basic reset and styles */
        *, *::before, *::after {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
            background: #ffffff;
        }

        /* Header styles */
        .header {
            background-color: #111a26; /* Teal color */
            color: white;
            padding: 20px;
            text-align: center;
            position: relative;
        }

        .header img {
            max-width: 500px; /* Adjust as necessary for your logo */
            height: auto;
        }

        /* Navigation-like button styles */
        .nav-buttons {
            display: flex;
            justify-content: center;
            margin-top: 30px;
        }

        .nav-button {
            background-color: #8ee2cd; /* Deep orange color */
            color: white;
            text-decoration: none;
            padding: 15px 30px;
            margin: 0 10px;
            border-radius: 4px;
            transition: background-color 0.3s ease;
            font-weight: bold;
        }

        .nav-button:hover {
            background-color: #14b58e; /* Darken on hover */
        }

        /* Content styles */
        .content {
            text-align: center;
            padding: 50px 20px;
            font-size: 1.2em;
        }
        footer {
            background-color: #333;
            color: #fff;
            text-align: center;
            padding: 10px 0;
            position: absolute;
            bottom: 0;
            width: 100%;
        }
    </style>
</head>
<body>

    <div class="header">
        <img src="/logo.png" alt="FFT - Future Flow Tech Logo">
    </div>

    <div class="nav-buttons">
        <!-- Links act like navigation buttons -->
        <a href="/wordpress" class="nav-button">WordPress</a>
        <a href="https://extra.g03-fft.internal" class="nav-button">services</a>
        <a href="/info.php" class="nav-button">More Info</a>
    </div>

    <div class="content">
        <p>Welcome to FFT - Future Flow Tech. Explore our services and technologies to power your future.</p>
    </div>
    <footer>
        <p>&copy; 2024 Future Flow Tech. All rights reserved.</p>
    </footer>
</body>
</html>
EOF

#extra website
mkdir /var/www/html/extra/
touch /var/www/html/extra/index.html
cat << 'EOF' >/var/www/html/extra/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FFT - Services</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f4f4f4;
        }

        header {
            background-color: #333;
            color: #fff;
            padding: 10px 0;
            text-align: center;
        }

        header h1 {
            margin: 0;
        }

        main {
            padding: 20px;
        }

        section {
            background-color: #fff;
            padding: 20px;
            margin: 20px 0;
            border-radius: 5px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        }

        footer {
            background-color: #333;
            color: #fff;
            text-align: center;
            padding: 10px 0;
            position: absolute;
            bottom: 0;
            width: 100%;
        }
    </style>
</head>
<body>
    <header>
        <h1>Future Flow Tech</h1>
    </header>
    <main>
        <section>
            <h2>Our Services</h2>
            <p>Welcome to FFT's services page. Here, you can find information about the services we offer to help power your future.</p>
            <ul>
                <li>Network Solutions</li>
                <li>Cloud Computing</li>
                <li>Data Management</li>
                <li>IT Consultancy</li>
            </ul>
        </section>
    </main>
    <footer>
        <p>&copy; 2024 Future Flow Tech. All rights reserved.</p>
    </footer>
</body>
</html>

EOF

#Creating info.php file
log "Creating info.php"
touch /var/www/html/info.php
cat << 'EOF' >/var/www/html/info.php
<p> Click <a href="/index.html">here</a> to go back to the index.
<?php phpinfo(); ?>

EOF

#Creating test.php file
log "Creating test.php"
touch /var/www/html/test.php
cat << 'EOF' >/var/www/html/test.php
<html>
<head>
<title>Demo</title>
<link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@400;900&display=swap" rel="stylesheet">
<style>
table, th, td {
  border-bottom: 1px solid black;
  padding: 10px;
  border-collapse: collapse;
  text-align: center;
}
.center {
  margin-left: auto;
  margin-right: auto;
}
h1 {
  text-align: center;
  font-size: 50px;
}
* {
  font-family: Montserrat;
  font-size: 20px;

}
</style>
</head>
<body>
<h1>Database Query Trial</h1>
<h2>Get back to the previous page by clicking <a href="/index.html">here</a>.</h2>

<?php
// Variables
$db_host='192.168.103.187:3306';
$db_user='www_user';
$db_name='trialsite';
$db_password='Kof3Cup.ByRu';
$db_table='trialsite_tbl';

// Connecting, selecting database
$connection = new mysqli($db_host, $db_user, $db_password, $db_name);

if ($connection->connect_error) {
                die("<p>Could not connect to database server:</p>" . $connection->connect_error);
}

// Performing SQL query
$query = "SELECT * FROM $db_table";
$result = $connection->query($query);

// Printing results in HTML
echo "<table class=\"center\">\n\t<tr><th>id</th><th>name</th></tr>\n";
while ($row = $result->fetch_assoc()) {
            echo "\t<tr>\n";
                echo "\t\t<td>" . $row["id"] . "</td>\n";
                echo "\t\t<td>" . $row["name"] . "</td>\n";
                    echo "\t</tr>\n";
}
echo "</table>\n";

$result->close();

$connection->close();
?>
</body>


EOF

#kopieren php bestanden
cd /var/www/html/
sudo cp info.php extra
sudo cp test.php extra

#maken vhosts
cd /etc/httpd/conf.d
# sudo touch extra.g03-fft.internal.conf
sudo touch g03-fft.internal.conf
# cat << 'EOF' >/etc/httpd/conf.d/extra.g03-fft.internal.conf
# <VirtualHost *:80>
#     ServerName extra.g03-fft.internal
#     DocumentRoot /var/www/html/extra/
#     <Directory /var/www/html/extra/>
#         AllowOverride All
#         Require all granted
#     </Directory>
# </VirtualHost>
# EOF

cat << 'EOF' >/etc/httpd/conf.d/g03-fft.internal.conf
<VirtualHost *:80>
    ServerName g03-fft.internal
    ServerAlias www.g03-fft.internal
    DocumentRoot /var/www/html/
    <Directory /var/www/html/>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>

#extra website
<VirtualHost *:80>
    ServerName extra.g03-fft.internal
    DocumentRoot /var/www/html/extra/
    <Directory /var/www/html/extra/>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF

sudo systemctl restart httpd

sudo ip route del default via 10.0.2.2 dev eth0
sudo ip route del 192.168.103.160/27 dev eth1

log "Provisioning complete"