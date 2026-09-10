#!/bin/sh
# Respawn loop for autoapp: keeps the kiosk app on screen even if it
# crashes or the display briefly goes away.

export QT_QPA_PLATFORM=eglfs
# No fontconfig on this image, so Qt's basic font database only looks in
# /usr/lib/fonts by default and finds nothing; point it at the ttf-dejavu
# package's install location instead.
export QT_QPA_FONTDIR=/usr/share/fonts/truetype
# This board's HDMI EDID read is intermittently unreliable -- the DRM
# connector reports "connected" but comes back with zero usable modes,
# and separately from that, Qt's own eglfs_kms output enumeration doesn't
# pick up the kernel's forced-mode fallback (see the "video=" kernel
# cmdline arg in tinker-board-openauto.wks). Force a known-good mode here
# too so Qt always has one to use regardless of what the connector reports.
export QT_QPA_EGLFS_KMS_CONFIG=/etc/eglfs_kms.json

while true; do
    /usr/bin/autoapp
    sleep 2
done
