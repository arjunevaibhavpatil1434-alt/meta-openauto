SUMMARY = "Android Auto SDK"
DESCRIPTION = "AASDK library used by OpenAuto"
HOMEPAGE = "https://github.com/f1xpl/aasdk"

LICENSE = "GPL-3.0-only"
LIC_FILES_CHKSUM = "file://include/f1x/aasdk/Messenger/FrameType.hpp;beginline=1;endline=16;md5=530a402a6139b8ffd254feceaee965b9"

SRC_URI = "git://github.com/f1xpl/aasdk.git;protocol=https;branch=development \
    file://0001-cmake-preserve-toolchain-cxx-flags.patch \
    file://0002-fix-boost-noncopyable-and-openssl3-compat.patch \
    file://0003-fix-boost-asio-strand-and-libusb-hotplug-flag.patch \
    file://0004-cmake-add-install-rules.patch \
    file://0005-fix-unaligned-timestamp-and-framesize-reads.patch \
    file://0006-fix-messenger-intertwined-channels-false-positive.patch \
    file://0007-fix-touch-proto3-zero-value-omission.patch \
"
SRCREV = "046b3b381595509d0939fa84b14a90978f46ff63"

S = "${WORKDIR}/git"

DEPENDS = " \
    boost \
    libusb1 \
    protobuf \
    protobuf-native \
    openssl \
"

inherit cmake pkgconfig

EXTRA_OECMAKE += " \
    -DAASDK_TEST=OFF \
    -DCMAKE_HAVE_PTHREAD_H=1 \
    -DCMAKE_HAVE_LIBC_PTHREAD=1 \
"

FILES_SOLIBSDEV = ""
FILES:${PN} += "${libdir}/libaasdk.so ${libdir}/libaasdk_proto.so"
FILES:${PN}-dev += "${includedir}"

INSANE_SKIP:${PN} += "dev-so"
