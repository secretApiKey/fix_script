#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ "$(id -u)" -ne 0 ]; then
    echo "Please run as root."
    exit 1
fi

echo "This will run the normal uninstall and then purge related packages."
echo "This is intended to get the VPS closer to a fresh baseline."
echo "Packages removed may include nginx, openvpn, squid, stunnel4, certbot, build tools, and helper utilities."
read -r -p "Type HARD-RESET to continue: " confirm
if [ "$confirm" != "HARD-RESET" ]; then
    echo "Cancelled."
    exit 0
fi

SKIP_CONFIRM=1 bash "$SCRIPT_DIR/uninstall.sh"

export DEBIAN_FRONTEND=noninteractive

apt-get purge -y \
    autoconf automake build-essential certbot cmake conntrack dnsutils dos2unix expect git golang jq \
    libpam0g-dev libssl-dev libtool nginx openvpn pkg-config python3-pam python3-pip \
    screenfetch squid sslh stunnel4 unzip zlib1g-dev || true

apt-get autoremove -y --purge || true
apt-get clean || true

rm -rf /var/lib/apt/lists/*
rm -rf /var/log/xray
rm -rf /etc/openvpn
rm -rf /etc/nginx
rm -rf /etc/squid
rm -rf /etc/stunnel
rm -rf /var/log/nginx
rm -rf /var/log/openvpn
rm -rf /var/log/squid
rm -rf /var/log/stunnel*

echo "Hard uninstall completed."
echo "The VPS should now be much closer to a fresh baseline."
