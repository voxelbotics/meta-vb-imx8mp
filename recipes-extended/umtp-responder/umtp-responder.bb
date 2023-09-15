SUMMARY = "uMTP-Responder is a lightweight USB Media Transfer Protocol (MTP) responder daemon for GNU/Linux"

LICENSE = "GPLv3"
LIC_FILES_CHKSUM = " file://LICENSE;md5=d32239bcb673463ab874e80d47fae504 "

SRC_URI = "git://github.com/viveris/uMTP-Responder.git;protocol=https;branch=master \
           file://umtprd.conf \
           "
SRCREV = "umtprd-1.3.6"
PV = "1.3.6+git${SRCPV}"

S = "${WORKDIR}/git"

do_configure () {
}

do_install () {
	install -d ${D}${sbindir}
	install -m 755 umtprd ${D}${sbindir}

	install -d ${D}${sysconfdir}/umtprd
	install -m 644 ${WORKDIR}/umtprd.conf ${D}${sysconfdir}/umtprd
}
