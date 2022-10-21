# Copyrigh (C) 2022 VoxelBotics
# Additional rootfs files

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = " \
	file://usb-gadgets.service \
	file://usb_gadgets.sh \
	file://wireless.network \
	file://nxp_depmod.conf \
	file://nxp_modules.conf \
	file://data.mount \
	file://install_update.sh \
	file://rollback_update.sh \
"

do_install() {
	install -d ${D}
	install -d ${D}/data
	install -d ${D}${sysconfdir}/
	install -d ${D}${sysconfdir}/depmod.d
	install -d ${D}${sysconfdir}/modprobe.d
	install -d ${D}${sysconfdir}/wpa_supplicant
	install -d ${D}${sysconfdir}/systemd/network
	install -d ${D}${systemd_system_unitdir}
	install -d ${D}${sbindir}
	install -d ${D}${systemd_system_unitdir}/multi-user.target.wants/
	install -d ${D}${systemd_system_unitdir}/local-fs.target.wants/

	# /data partition automount
	install -m 0644 ${WORKDIR}/data.mount ${D}${systemd_system_unitdir}
	ln -s /lib/systemd/system/data.mount ${D}${systemd_system_unitdir}/local-fs.target.wants/data.mount

	# USB gadget service
	install -m 0755 ${WORKDIR}/usb_gadgets.sh ${D}${sbindir}
	install -m 0644 ${WORKDIR}/usb-gadgets.service ${D}${systemd_system_unitdir}
	ln -s /lib/systemd/system/usb-gadgets.service ${D}${systemd_system_unitdir}/multi-user.target.wants/usb-gadgets.service

	# WiFi configuration
	install -m 0644 ${WORKDIR}/wireless.network ${D}${sysconfdir}/systemd/network
	install -m 0644 ${WORKDIR}/nxp_depmod.conf ${D}${sysconfdir}/depmod.d
	install -m 0644 ${WORKDIR}/nxp_modules.conf ${D}${sysconfdir}/modprobe.d
	ln -sf /data/etc/wpa_supplicant/wpa_supplicant-mlan0.conf ${D}${sysconfdir}/wpa_supplicant/wpa_supplicant-mlan0.conf
	ln -s /lib/systemd/system/wpa_supplicant@.service ${D}${systemd_system_unitdir}/multi-user.target.wants/wpa_supplicant@mlan0.service

	# populate /data/etc for SD card boot which doesn't have a separate data partition
	install -d ${D}/data/etc/wpa_supplicant/
	echo -e "ctrl_interface=/var/run/wpa_supplicant\nctrl_interface_group=0\nupdate_config=1\n\n" > ${D}/data/etc/wpa_supplicant/wpa_supplicant-mlan0.conf
	echo -e "network={\nssid=\"SSID\"\nscan_ssid=1\npsk=\"password\"\n}\n" >> ${D}/data/etc/wpa_supplicant/wpa_supplicant-mlan0.conf

	# access to U-Boot env
	echo "/dev/mmcblk2    0x400000        0x4000" > ${D}${sysconfdir}/fw_env.config
	ln -sf u-boot-imx-initial-env ${D}${sysconfdir}/u-boot-initial-env

	echo "${SWU_BOARD} ${SWU_HWCOMPAT}" > ${D}${sysconfdir}/hwrevision
	echo -e "bootloader\t\t${SWU_UBOOT_VERSION}" > ${D}${sysconfdir}/sw-versions

	install -m 0755 ${WORKDIR}/install_update.sh ${D}${sbindir}
	install -m 0755 ${WORKDIR}/rollback_update.sh ${D}${sbindir}
}

PACKAGE_ARCH = "${MACHINE_ARCH}"

FILES:${PN} += "/data /etc /lib /usr"
