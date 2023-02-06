# Copyrigh (C) 2022 VoxelBotics
# wpa_supplicant configs

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = " \
	file://wireless.network \
"

SERVICE_LINKS_DIR = "${sysconfdir}/systemd/system/multi-user.target.wants"

do_install() {
	install -d ${D}
	install -d ${D}/data
	install -d ${D}${sysconfdir}/wpa_supplicant
	install -d ${D}${sysconfdir}/systemd/network
	install -d ${D}${SERVICE_LINKS_DIR}

	# WiFi configuration
	install -m 0644 ${WORKDIR}/wireless.network ${D}${sysconfdir}/systemd/network
	ln -sf /data/etc/wpa_supplicant/wpa_supplicant-mlan0.conf ${D}${sysconfdir}/wpa_supplicant/wpa_supplicant-mlan0.conf
	ln -s /lib/systemd/system/wpa_supplicant@.service ${D}${SERVICE_LINKS_DIR}/wpa_supplicant@mlan0.service

	# populate /data/etc for SD card boot which doesn't have a separate data partition
	install -d ${D}/data/etc/wpa_supplicant/
	echo -e "ctrl_interface=/var/run/wpa_supplicant\nctrl_interface_group=0\nupdate_config=1\n\n" > ${D}/data/etc/wpa_supplicant/wpa_supplicant-mlan0.conf
	echo -e "network={\nssid=\"SSID\"\nscan_ssid=1\npsk=\"password\"\n}\n" >> ${D}/data/etc/wpa_supplicant/wpa_supplicant-mlan0.conf
}

PACKAGE_ARCH = "${MACHINE_ARCH}"

RDEPENDS:${PN} = "navq-kmod-mlan"

FILES:${PN} = " \
	/data \
	${sysconfdir}/systemd/network \
	${sysconfdir}/wpa_supplicant \
	${SERVICE_LINKS_DIR}/wpa_supplicant@mlan0.service \
"
