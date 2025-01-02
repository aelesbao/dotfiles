#!/usr/bin/env zsh
#
# Ansible setup
#

set -euo pipefail

require ansible

info "Ansible setup"

SCRIPT_PATH="${0:A:h}"
ANSIBLE_ROOT="${SCRIPT_PATH}/../../ansible"

pushd "$ANSIBLE_ROOT"

msg "Installing Ansible collections and roles"
ansible-galaxy install -r requirements.yml

msg "Running Ansible playbook"
ansible-playbook playbook.yml --ask-become-pass

popd
