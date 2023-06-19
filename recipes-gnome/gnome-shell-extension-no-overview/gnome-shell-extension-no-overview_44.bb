#
# No overview gnome-shell extension
# https://extensions.gnome.org/extension/4099/no-overview/
#
# Copyrigh (C) 2023 Voxelbotics
#
LICENSE = "GPL3"
LIC_FILES_CHKSUM = "file://${S}/no-overview-${PV}/LICENSE;md5=1ebbd3e34237af26da5dc08a4e440464"

SRC_URI = "https://github.com/fthx/no-overview/archive/refs/tags/v${PV}.tar.gz"
SRC_URI[sha256sum] = "7c381f4645657d7bf09160e3f094273162d2f53883701e24c072d1d48f3ca9a2"

S = "${WORKDIR}"

do_install () {
	install -d ${D}${datadir}/gnome-shell/extensions/no-overview@fthx
	cp ${S}/no-overview-44/* ${D}${datadir}/gnome-shell/extensions/no-overview@fthx/
}

FILES:${PN} += "${datadir}/gnome-shell/extensions/no-overview@fthx/*"
