#!/bin/sh
# Respawn loop for autoapp: keeps the kiosk app on screen even if it
# crashes or the display briefly goes away.

export QT_QPA_PLATFORM=eglfs
# No fontconfig on this image, so Qt's basic font database only looks in
# /usr/lib/fonts by default and finds nothing; point it at the ttf-dejavu
# package's install location instead.
export QT_QPA_FONTDIR=/usr/share/fonts/truetype

while true; do
    /usr/bin/autoapp
    sleep 2
done
