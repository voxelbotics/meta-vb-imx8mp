# ecpprog - a basic driver for FTDI based JTAG probes (FT232H, FT2232H, FT4232H), to
# program Lattice ECP5/Nexus FPGAs.

LICENSE = "ISC"
LIC_FILES_CHKSUM = "file://COPYING;md5=912e088c1140f3804f3d972873f99c97"

SRC_URI = "git://github.com/gregdavill/ecpprog.git;protocol=https;branch=main \
           file://0001-Add-IDCODE-for-the-LIFCL-33U-device.patch \
           "
SRCREV = "${AUTOREV}"
PV = "1.0.0+git${SRCPV}"

DEPENDS = "libftdi"
RDEPENDS_${PN} = "libftdi"

S = "${WORKDIR}/git"
B = "${S}/${PN}"

inherit pkgconfig

do_install () {
	install -d ${D}/${sbindir}
	install ${S}/${PN}/${PN} ${D}/${sbindir}/${PN}
}

FILES_${PN} = "${sbindir}/${PN}"
