#!/bin/sh
# Headless WiFi join. connmanctl's built-in agent prompts interactively
# for the passphrase, which doesn't work over a scripted/serial session
# with no display. Instead this writes a connman provisioning file (the
# documented non-interactive method - see connman's doc/config-format.txt)
# so connman associates on its own next time it sees the SSID in a scan.
set -e

SSID="$1"
PASSPHRASE="$2"

if [ -z "$SSID" ]; then
    echo "Usage: wifi-connect <SSID> [passphrase]" >&2
    exit 1
fi

# connman group names must be alnum-only; the SSID itself (Name=) can be
# anything and is what actually gets matched against the scan result.
GROUP=$(echo "$SSID" | tr -c 'A-Za-z0-9' '_')
CONF="/var/lib/connman/wifi_${GROUP}.config"

mkdir -p /var/lib/connman
{
    echo "[service_${GROUP}]"
    echo "Type = wifi"
    echo "Name = ${SSID}"
    [ -n "$PASSPHRASE" ] && echo "Passphrase = ${PASSPHRASE}"
} > "$CONF"
chmod 600 "$CONF"

echo "Wrote ${CONF}; scanning for ${SSID}..."
connmanctl enable wifi >/dev/null 2>&1 || true
connmanctl scan wifi >/dev/null 2>&1 || true

# connman picks up the new provisioning file and auto-connects once the
# SSID shows up in a scan; give it a few seconds before reporting status.
i=0
while [ "$i" -lt 10 ]; do
    connmanctl services 2>/dev/null | grep -F -- "${SSID}" && break
    i=$((i + 1))
    sleep 1
done

connmanctl services
