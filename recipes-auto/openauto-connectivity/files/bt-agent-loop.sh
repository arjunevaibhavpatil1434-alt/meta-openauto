#!/bin/sh
# Keeps bluetoothctl alive as a registered NoInputNoOutput agent so
# incoming pairing requests from a phone (needed for AndroidAuto's
# Bluetooth channel and for wireless-mode auto-launch) are accepted
# without a keyboard or display attached. Respawns if bluetoothd
# restarts or the adapter is reset.

while true; do
    {
        echo "power on"
        echo "discoverable on"
        echo "pairable on"
        echo "agent NoInputNoOutput"
        echo "default-agent"
        # Keep stdin open so bluetoothctl doesn't exit and drop the
        # agent registration.
        sleep infinity
    } | bluetoothctl >/var/log/bt-agent.log 2>&1
    sleep 2
done
