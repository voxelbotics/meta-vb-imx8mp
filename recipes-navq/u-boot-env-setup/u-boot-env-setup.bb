# Copyright (C) 2023 VoxelBotics
# U-boot env helper service

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = " \
	file://u-boot-env-setup.sh \
	file://u-boot-env-setup.service \
"

inherit systemd

do_install() {
	install -d ${D}${sysconfdir}
	install -d ${D}${sbindir}
	install -d ${D}${systemd_system_unitdir}

	echo "/dev/mmcblk1	0x400000	0x4000" > ${D}${sysconfdir}/fw_env.config_sd
	echo "/dev/mmcblk2	0x400000	0x4000" > ${D}${sysconfdir}/fw_env.config_emmc

	install -m 0755 ${WORKDIR}/u-boot-env-setup.sh ${D}${sbindir}
	install -m 0644 ${WORKDIR}/u-boot-env-setup.service ${D}${systemd_system_unitdir}
}

SYSTEMD_AUTO_ENABLE = "enable"
SYSTEMD_SERVICE:${PN} = "u-boot-env-setup.service"
FILES:${PN} += "${systemd_system_unitdir}"
