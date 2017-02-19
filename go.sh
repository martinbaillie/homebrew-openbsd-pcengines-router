#!/usr/bin/env bash

: "${PYTHON_VERSION:=2.7.13}"

# Bootstrap
ansible -m raw -c paramiko -u "${USER}" -k \
    -b --become-method=su --ask-su-pass -a \
    "PKG_PATH=https://ftp.openbsd.org/pub/OpenBSD/snapshots/packages/amd64 \
    pkg_add python-${PYTHON_VERSION}" -i "$1," "$1"

# 1st pass
ansible-playbook bootstrap.yml -kKi "$1,"

# Main event
ansible-playbook provision.yml -i "$1,"
