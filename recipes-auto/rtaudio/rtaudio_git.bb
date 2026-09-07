SUMMARY = "A set of realtime audio i/o C++ classes"
DESCRIPTION = "RtAudio provides a common API (Application Programming Interface) for realtime audio input/output, used by openauto for audio playback"
HOMEPAGE = "https://github.com/thestk/rtaudio"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=34bd14de91674a563fe79386431546bb"

# Pinned to the last 5.x release: openauto's RtAudioOutput.cpp uses the
# classic exception-based API (RtAudioError, void-returning openStream())
# that RtAudio 6.0 removed in favor of RtAudioErrorType return codes.
SRC_URI = "git://github.com/thestk/rtaudio.git;protocol=https;branch=master"
SRCREV = "46b01b5b134f33d8ddc3dab76829d4b1350e0522"

S = "${WORKDIR}/git"

# alsa-lib: default RTAUDIO_API_ALSA backend.
# pulseaudio: openauto's RtAudioOutput prefers RtAudio::LINUX_PULSE when
# available, falling back to the default (ALSA) API otherwise.
DEPENDS = "alsa-lib pulseaudio"

inherit cmake pkgconfig

EXTRA_OECMAKE += " \
    -DCMAKE_HAVE_PTHREAD_H=1 \
    -DCMAKE_HAVE_LIBC_PTHREAD=1 \
    -DRTAUDIO_BUILD_TESTING=OFF \
"

FILES:${PN} += "${libdir}/librtaudio.so.*"
FILES:${PN}-dev += "${libdir}/librtaudio.so"
