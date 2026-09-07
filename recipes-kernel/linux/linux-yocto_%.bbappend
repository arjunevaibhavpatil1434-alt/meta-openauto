FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# Merged in by kernel-yocto's do_kernel_metadata/merge_config; no .scc
# wrapper needed for a plain Kconfig fragment.
SRC_URI:append:tinker-board = " file://openauto-connectivity.cfg"
SRC_URI:append:tinker-board-s = " file://openauto-connectivity.cfg"
