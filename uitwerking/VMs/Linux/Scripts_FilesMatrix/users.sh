#!/bin/bash
# Script to register users on the Matrix Synapse server

set -o errexit
set -o nounset
set -o pipefail

SYNAPSE_VENV_DIR="/home/vagrant/synapse"
source "$SYNAPSE_VENV_DIR/bin/activate"

register_new_matrix_user -c /home/vagrant/synapse/homeserver.yaml http://localhost:8008 -u Jasper -p 23User24 -a
register_new_matrix_user -c /home/vagrant/synapse/homeserver.yaml http://localhost:8008 -u Jorik -p 23User24 -a

