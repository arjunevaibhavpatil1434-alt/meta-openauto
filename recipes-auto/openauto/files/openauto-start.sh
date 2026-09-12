#!/bin/sh
# Respawn loop for autoapp: keeps the kiosk app on screen even if it
# crashes or the display briefly goes away.

# Configuration::cConfigFileName ("openauto.ini") is a relative path, so
# autoapp reads whatever "openauto.ini" resolves to in ITS cwd, not a
# fixed location. The real, hand-tuned config (matching the verified
# 1280x720 scanout -- see /home/root/openauto.ini's own comments) is
# installed at /home/root/openauto.ini specifically so that running
# autoapp with cwd=/home/root picks it up. Without this cd, cwd stays
# "/" (inherited from init), so autoapp instead reads/creates
# /openauto.ini with boost::property_tree's built-in defaults
# (Resolution=1/_480p, ScreenDPI=140) -- wrong for this panel's actual
# 1280x720 HDMI scanout mode.
cd /home/root || exit 1

export QT_QPA_PLATFORM=eglfs
# No fontconfig on this image, so Qt's basic font database only looks in
# /usr/lib/fonts by default and finds nothing; point it at the ttf-dejavu
# package's install location instead.
export QT_QPA_FONTDIR=/usr/share/fonts/truetype
# AndroidAuto maps its declared touch_screen_config (see ServiceFactory.cpp
# / InputService::fillFeatures) to its own rendered video resolution
# internally; InputDevice sends raw, unscaled touch coordinates to match
# (see AUTOAPP_TOUCH_OFFSET_X/Y support added there). On real hardware
# testing that raw passthrough still lands a fixed one-icon-width off:
# tapping one app icon in AA's launcher row consistently opened the next
# icon over. -150 on X was found empirically (binary search against actual
# taps: 0 overshot by ~1 icon-width right, +150 overshot by ~2, -150
# measured correct across several different icons) and reliably corrects
# it; Y has not shown a similar error so is left at 0. If this board's
# panel, cable, or AA app version changes, re-verify by tapping a few
# named icons with AUTOAPP_TOUCH_OFFSET_X=0 first.
export AUTOAPP_TOUCH_OFFSET_X=-150
export AUTOAPP_TOUCH_OFFSET_Y=0
# EDID *is* readable on this board (128 bytes, valid) via
# /sys/class/drm/*-HDMI-A-*/edid -- do not trust a claim that it reads
# back 0 bytes without re-checking directly (scp of that sysfs file always
# reads 0 bytes since it isn't a seekable regular file; `ssh ... cat ...`
# works). Its decoded preferred timing (1024x600, 49.000MHz, 60Hz,
# negative sync) was tried directly against Qt's eglfs_kms "mode" config,
# alongside two independently hand-computed CVT/reduced-blanking-CVT
# modelines and a vendor-timing guess from a forum post -- all four,
# structurally different, mathematically valid attempts were rejected
# outright by the DRM driver (verified via
# /sys/kernel/debug/dri/*/state: enable=0 active=0 / "Invalid argument"
# from Qt). This board's VOP/HDMI combo cannot generate a 1024x600 pixel
# clock at all -- a hardware/PLL limitation, not a timing-precision or
# polarity problem -- so don't spend further effort on alternate
# modelines for native resolution.
#
# What does work is the kernel's own mode-setting: the "video="
# cmdline arg in tinker-board-openauto.wks (also targeting 1024x600@60)
# successfully drives the generic fbdev/fbcon client, confirmed by
# "[drm] fb0: rockchipdrmfb frame buffer device" in dmesg. Rather than
# have Qt renegotiate its own modeline through a path that's
# demonstrably less tolerant, "mode": "current" in eglfs_kms.json
# tells Qt to just read back and reuse whatever mode is already
# programmed into the CRTC hardware at the time autoapp starts (see
# QKmsDevice::createScreenForConnector's OutputConfigCurrent handling
# in qtbase) -- i.e. the kernel's already-working mode, instead of
# independently deriving a second one that keeps getting rejected.
export QT_QPA_EGLFS_KMS_CONFIG=/etc/eglfs_kms.json

# The rockchip-drm (real display, has connectors) vs panfrost (Mali GPU,
# no display capability) DRM minor numbers are NOT stable across boots on
# this hardware -- which one lands on /dev/dri/card0 vs card1 depends on
# kernel driver probe ordering (see the 'Fixing up cyclic dependency'
# messages between the HDMI and VOP drivers in dmesg), and flips often.
# A hardcoded card number in eglfs_kms.json is therefore wrong about half
# the time, which made Qt/eglfs either report "no screens available" or
# segfault outright depending on what card0 happened to be. Re-detect the
# card bound to the display-subsystem platform device on every boot
# instead, by driver binding rather than by number, and patch it into the
# KMS config just before launching.
for c in /sys/class/drm/card*; do
    case "$(basename "$c")" in card*-*) continue;; esac
    if readlink -f "$c/device" | grep -q display-subsystem; then
        DISPLAY_CARD="/dev/dri/$(basename "$c")"
        break
    fi
done

if [ -n "$DISPLAY_CARD" ]; then
    sed -i "s#\"device\": \"/dev/dri/card[0-9]*\"#\"device\": \"$DISPLAY_CARD\"#" /etc/eglfs_kms.json
fi

# Pre-warm the ALSA dmix slave before autoapp ever touches it. The instant
# an AndroidAuto session connects, autoapp opens three concurrent
# RtAudio/ALSA streams (MEDIA_AUDIO, SPEECH_AUDIO, SYSTEM_AUDIO -- see
# AudioService::start in openauto), all racing to attach to the "dmixer"
# dmix plugin in /etc/asound.conf at the same instant. That concurrent
# cold-start attach has been observed to leave the shared hardware ring
# buffer's write pointer permanently stuck at 0
# (/proc/asound/card0/pcm2p/sub0/status shows state RUNNING with hw_ptr
# advancing but appl_ptr frozen forever) -- the stream plays silence with
# no error anywhere, on RtAudio's side or ALSA's. Keeping one silent
# stream already open on dmixer here means the dmix slave has a single,
# stable owner and fully initialized ring buffer before autoapp starts,
# so its three simultaneous opens are ordinary attaches instead of a
# racy first-attach negotiation.
(
    while true; do
        aplay -q -D dmixer -f S16_LE -r 48000 -c 2 /dev/zero 2>/dev/null
        sleep 1
    done
) &

while true; do
    /usr/bin/autoapp
    sleep 2
done
