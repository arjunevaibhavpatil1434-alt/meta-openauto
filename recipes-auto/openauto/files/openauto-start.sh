#!/bin/sh
# Respawn loop for autoapp: keeps the kiosk app on screen even if it
# crashes or the display briefly goes away.

export QT_QPA_PLATFORM=eglfs

while true; do
    /usr/bin/autoapp
    sleep 2
done
