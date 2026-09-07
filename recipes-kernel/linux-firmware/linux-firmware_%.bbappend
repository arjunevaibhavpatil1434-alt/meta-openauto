# The upstream recipe's rtl8723 package only globs the WiFi firmware
# (rtlwifi/rtl8723*.bin); the RTL8723BU/DU combo dongle's Bluetooth side
# (btusb + hci_h4/rtl driver) loads rtl_bt/rtl8723*.bin, which isn't
# claimed by any package there and would otherwise be silently dropped.
FILES:${PN}-rtl8723 += "${nonarch_base_libdir}/firmware/rtl_bt/rtl8723*.bin"
