# Copyrigh (C) 2022 VoxelBotics
# Wifi driver configs

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = " \
	file://nxp_depmod.conf \
	file://nxp_modules.conf \
"

do_install() {
	install -d ${D}
	install -d ${D}${sysconfdir}/depmod.d
	install -d ${D}${sysconfdir}/modprobe.d

	install -m 0644 ${WORKDIR}/nxp_depmod.conf ${D}${sysconfdir}/depmod.d
	install -m 0644 ${WORKDIR}/nxp_modules.conf ${D}${sysconfdir}/modprobe.d
}

PACKAGE_ARCH = "${MACHINE_ARCH}"

FILES:${PN} = "${sysconfdir}"
