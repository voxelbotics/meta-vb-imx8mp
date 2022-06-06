# Copyrigh (C) 2022 VoxelBotics
# Additional rootfs files

LICENSE = "CLOSED"

SRC_URI = " \
	file://usb-gadgets.service \
	file://usb_gadgets.sh \
	file://wireless.network \
	file://nxp_depmod.conf \
	file://nxp_modules.conf \
	file://data.mount \
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
}

PACKAGE_ARCH = "${MACHINE_ARCH}"

FILES:${PN} += "/data /etc /lib /usr"
