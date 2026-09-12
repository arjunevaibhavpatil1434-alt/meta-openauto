# Forcing a display mode via the wks file's "bootloader --append" (see
# tinker-board-openauto.wks) has no effect on this board: that flag only
# feeds wic's own U-Boot environment/boot.scr generation, but this BSP
# actually boots through U-Boot's distro-boot extlinux mechanism --
# /boot/extlinux/extlinux.conf, generated at build time by
# uboot-extlinux-config.bbclass from UBOOT_EXTLINUX_KERNEL_ARGS -- which
# the wks file never touches. Confirmed via /proc/cmdline on a booted
# device: no "video=" argument ever reached the kernel despite it being
# set in the wks file, because extlinux.conf's own "append" line (built
# from UBOOT_EXTLINUX_KERNEL_ARGS, default "rootwait rw") doesn't
# include it. This is the actual place the forced HDMI mode needs to be
# added for it to ever reach the kernel command line.
UBOOT_EXTLINUX_KERNEL_ARGS:tinker-board:append = " video=HDMI-A-1:1024x600@60"
UBOOT_EXTLINUX_KERNEL_ARGS:tinker-board-s:append = " video=HDMI-A-1:1024x600@60"
