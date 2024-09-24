#! /bin/bash
#
# Provisioning script common for all servers

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
# TODO: put all variable definitions here. Tip: make them readonly if possible.

export readonly INTERFACE="eth1"
export readonly STATIC_IP_TFTP="192.168.103.138"
export readonly STATIC_IP_WEB="192.168.103.186"
export readonly STATIC_IP_REDUNDANTWEB="192.168.103.182"
export readonly STATIC_IP_DB="192.168.103.187"
export readonly STATIC_IP_PROXY="192.168.103.155"
export readonly STATIC_IP_NEXTCLOUD="192.168.103.183"
export readonly STATIC_IP_CA="192.168.103.154"

export readonly NETWORK_VLAN1="192.168.103.128"
export readonly NETWORK_VLAN42="192.168.103.160"

export readonly NETMASK_VLAN1="255.255.255.240"
export readonly NETMASK_VLAN11="255.255.255.128"
export readonly NETMASK_VLAN13="255.255.255.240"
export readonly NETMASK_VLAN42="255.255.255.224"

export readonly GATEWAY_VLAN1="192.168.103.142"
export readonly GATEWAY_VLAN11="192.168.103.126"
export readonly GATEWAY_VLAN13="192.168.103.158"
export readonly GATEWAY_VLAN42="192.168.103.190"




# Set to 'yes' if debug messages should be printed.
readonly debug_output='yes'

#------------------------------------------------------------------------------
# Helper functions
#------------------------------------------------------------------------------
# Three levels of logging are provided: log (for messages you always want to
# see), debug (for debug output that you only want to see if specified), and
# error (obviously, for error messages).

# Usage: log [ARG]...
#
# Prints all arguments on the standard error stream
log() {
  printf '\e[0;33m[LOG]  %s\e[0m\n' "${*}"
}

# Usage: debug [ARG]...
#
# Prints all arguments on the standard error stream
debug() {
  if [ "${debug_output}" = 'yes' ]; then
    printf '\e[0;36m[DBG] %s\e[0m\n' "${*}"
  fi
}

# Usage: error [ARG]...
#
# Prints all arguments on the standard error stream
error() {
  printf '\e[0;31m[ERR] %s\e[0m\n' "${*}" 1>&2
}

#------------------------------------------------------------------------------
# Provisioning tasks
#------------------------------------------------------------------------------

log '=== Starting common provisioning tasks ==='

# TODO: insert common provisioning code here, e.g. install EPEL repository, add
# users, enable SELinux, etc.

log "Ensuring SELinux is active"

if [ "$(getenforce)" != 'Enforcing' ]; then
    # Enable SELinux now
    setenforce 1

    # Change the config file
    sed -i 's/SELINUX=.*/SELINUX=enforcing/' /etc/selinux/config
fi

log "Installing useful packages"

dnf install -y \
    bind-utils \
    cockpit \
    nano \
    tree

log "Enabling essential services"

systemctl enable --now firewalld.service
systemctl enable --now cockpit.socket
