SUMMARY = "AndroidAuto headunit emulator"
DESCRIPTION = "OpenAuto is a Qt5-based AndroidAuto headunit application, built on top of aasdk"
HOMEPAGE = "https://github.com/f1xpl/openauto"

LICENSE = "GPL-3.0-only"
LIC_FILES_CHKSUM = "file://include/f1x/openauto/autoapp/App.hpp;beginline=1;endline=16;md5=1b834683f77965329afad2f36beacedf"

SRC_URI = "git://github.com/f1xpl/openauto.git;protocol=https;branch=development \
    file://0001-cmake-fixes.patch \
    file://0002-fix-videoservice-missing-stop-indication.patch \
    file://openauto.init \
    file://openauto-start.sh \
"
SRCREV = "aa90412bf93b5a5078495ea85ac9270c6297d369"

S = "${WORKDIR}/git"

DEPENDS = " \
    aasdk \
    boost \
    libusb1 \
    protobuf \
    protobuf-native \
    openssl \
    rtaudio \
    qtbase \
    qtmultimedia \
    qtconnectivity \
"

inherit cmake_qt5 pkgconfig update-rc.d

EXTRA_OECMAKE += " \
    -DCMAKE_HAVE_PTHREAD_H=1 \
    -DCMAKE_HAVE_LIBC_PTHREAD=1 \
    -DAASDK_INCLUDE_DIRS=${STAGING_INCDIR} \
    -DAASDK_PROTO_INCLUDE_DIRS=${STAGING_INCDIR} \
    -DAASDK_LIBRARIES=${STAGING_LIBDIR}/libaasdk.so \
    -DAASDK_PROTO_LIBRARIES=${STAGING_LIBDIR}/libaasdk_proto.so \
"

INITSCRIPT_NAME = "openauto"
INITSCRIPT_PARAMS = "start 99 5 . stop 20 0 1 6 ."

do_install:append() {
    install -d ${D}${sysconfdir}/init.d
    install -m 0755 ${WORKDIR}/openauto.init ${D}${sysconfdir}/init.d/openauto

    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/openauto-start.sh ${D}${bindir}/openauto-start.sh
}

FILES:${PN} += "${bindir}/autoapp ${bindir}/btservice ${bindir}/openauto-start.sh ${sysconfdir}/init.d/openauto"
