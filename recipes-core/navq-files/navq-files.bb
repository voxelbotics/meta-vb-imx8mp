# Copyrigh (C) 2022 VoxelBotics
# Root filesystem image

LICENSE = "CLOSED"

inherit deploy

SRC_URI = " \
	file://usb-gadgets.service \
	file://usb_gadgets.sh \
"

do_deploy() {
	install -d ${DEPLOYDIR}${sysconfdir}/
	install -d ${DEPLOYDIR}${systemd_system_unitdir}
	install -d ${DEPLOYDIR}${sbindir}
	install -d ${DEPLOYDIR}${systemd_system_unitdir}/multi-user.target.wants/

	install -m 0755 ${WORKDIR}/usb_gadgets.sh ${DEPLOYDIR}${sbindir}
	install -m 0644 ${WORKDIR}/usb-gadgets.service ${DEPLOYDIR}${systemd_system_unitdir}
	ln -s /lib/systemd/system/usb-gadgets.service ${DEPLOYDIR}${systemd_system_unitdir}/multi-user.target.wants/usb-gadgets.service
}

addtask deploy after do_compile

PACKAGE_ARCH = "${MACHINE_ARCH}"
