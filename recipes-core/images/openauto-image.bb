SUMMARY = "AndroidAuto head unit image (OpenAuto) with wired/wireless/Bluetooth connectivity"
DESCRIPTION = "Boots straight into OpenAuto's autoapp kiosk (openauto.init) \
    with the connectivity stack it needs already wired up: \
    - wired AndroidAuto: USB host + aasdk/libusb AOAP detection \
    - wireless AndroidAuto: WiFi client connectivity (connman) so the \
      head unit can reach a phone's IP over the ConnectDialog \
    - Bluetooth: bluez5 + a headless auto-pairing agent (bt-agent), \
      since a kiosk box has no keyboard to confirm pairing on"

LICENSE = "MIT"

inherit core-image

IMAGE_FEATURES += "splash ssh-server-dropbear"

CORE_IMAGE_EXTRA_INSTALL += " \
    openauto \
    openauto-connectivity \
    kernel-modules \
    usbutils \
    alsa-utils \
    linux-firmware-rtl8192cu \
"
