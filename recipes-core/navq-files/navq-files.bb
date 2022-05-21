# Copyrigh (C) 2022 VoxelBotics
# Root filesystem image

LICENSE = "CLOSED"

SRC_URI = " \
	file://usb-gadgets.service \
	file://usb_gadgets.sh \
"

do_install() {
	install -d ${D}
	install -d ${D}${sysconfdir}/
	install -d ${D}${systemd_system_unitdir}
	install -d ${D}${sbindir}
	install -d ${D}${systemd_system_unitdir}/multi-user.target.wants/

	install -m 0755 ${WORKDIR}/usb_gadgets.sh ${D}${sbindir}
	install -m 0644 ${WORKDIR}/usb-gadgets.service ${D}${systemd_system_unitdir}
	ln -s /lib/systemd/system/usb-gadgets.service ${D}${systemd_system_unitdir}/multi-user.target.wants/usb-gadgets.service
}

PACKAGE_ARCH = "${MACHINE_ARCH}"

FILES:${PN} += "/etc /lib /usr"