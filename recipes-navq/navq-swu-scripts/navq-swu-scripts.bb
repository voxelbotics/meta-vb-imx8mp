# Copyrigh (C) 2022 VoxelBotics
# SWUpdate scripts

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = " \
	file://install_update.sh \
	file://rollback_update.sh \
"

do_install() {
	install -d ${D}
	install -d ${D}${sysconfdir}/
	install -d ${D}${sbindir}

	echo "${SWU_BOARD} ${SWU_HWCOMPAT}" > ${D}${sysconfdir}/hwrevision
	echo -e "bootloader\t\t${SWU_UBOOT_VERSION}" > ${D}${sysconfdir}/sw-versions

	install -m 0755 ${WORKDIR}/install_update.sh ${D}${sbindir}
	install -m 0755 ${WORKDIR}/rollback_update.sh ${D}${sbindir}
}

PACKAGE_ARCH = "${MACHINE_ARCH}"

FILES:${PN} = "${sysconfdir} ${sbindir}"
