SUMMARY = "Headless WiFi/Bluetooth glue for the OpenAuto head unit"
DESCRIPTION = "Pulls in the runtime bits OpenAuto itself doesn't provide: \
    the network stack for wired/wireless AndroidAuto (USB host + WiFi \
    client) and a headless Bluetooth pairing agent, since OpenAuto's own \
    RemoteBluetoothDevice::pair() just trusts the OS to already have \
    paired the phone."

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = " \
    file://bt-agent.init \
    file://bt-agent-loop.sh \
    file://wifi-connect.sh \
"

S = "${WORKDIR}"

inherit update-rc.d allarch

INITSCRIPT_NAME = "bt-agent"
INITSCRIPT_PARAMS = "start 98 5 . stop 21 0 1 6 ."

do_install() {
    install -d ${D}${sysconfdir}/init.d
    install -m 0755 ${WORKDIR}/bt-agent.init ${D}${sysconfdir}/init.d/bt-agent

    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/bt-agent-loop.sh ${D}${bindir}/bt-agent-loop.sh
    install -m 0755 ${WORKDIR}/wifi-connect.sh ${D}${bindir}/wifi-connect
}

FILES:${PN} += "${sysconfdir}/init.d/bt-agent ${bindir}/bt-agent-loop.sh ${bindir}/wifi-connect"

# bluez5: bluetoothd + bluetoothctl for the pairing agent.
# connman: WiFi client connectivity for wireless AA (OpenAuto's
#   ConnectDialog just TCP-connects to a phone IP already reachable on
#   the network - it does no AP/association work itself) with a
#   headless-friendly CLI (connmanctl) for joining a network without a
#   display attached. Its "wifi"/"bluez" PACKAGECONFIG are already
#   enabled by DISTRO_FEATURES, which pulls in wpa-supplicant itself -
#   don't RDEPEND on wpa-supplicant here too, or you get two unmanaged
#   supplicants fighting over the same interface.
# iw: headless WiFi diagnostics (site survey, link status).
RDEPENDS:${PN} = " \
    bluez5 \
    connman \
    iw \
"
