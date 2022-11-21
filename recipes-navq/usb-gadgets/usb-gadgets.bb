# Copyrigh (C) 2022 VoxelBotics
# Various USB gadgets

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = " \
	file://usb-gadget-eth@.service \
	file://usb-gadget-mtp@.service \
	file://usb-gadget-uuc@.service \
	file://usb-gadget-eth.sh \
	file://usb-gadget-mtp.sh \
	file://usb-gadget-uuc.sh \
"

# NAVQ+ USB ports
USB_PORT1 ?= "38100000.usb"
USB_PORT2 ?= "38200000.usb"

do_install() {
	install -d ${D}

	# USB gadget scripts
	install -d ${D}${sbindir}
	install -m 0755 ${WORKDIR}/usb-gadget-eth.sh ${D}${sbindir}
	install -m 0755 ${WORKDIR}/usb-gadget-mtp.sh ${D}${sbindir}
	install -m 0755 ${WORKDIR}/usb-gadget-uuc.sh ${D}${sbindir}

	# USB gadget services
	install -d ${D}${systemd_system_unitdir}
	install -m 0644 ${WORKDIR}/usb-gadget-eth@.service ${D}${systemd_system_unitdir}
	install -m 0644 ${WORKDIR}/usb-gadget-mtp@.service ${D}${systemd_system_unitdir}
	install -m 0644 ${WORKDIR}/usb-gadget-uuc@.service ${D}${systemd_system_unitdir}

	# install port-specific links
	install -d ${D}${systemd_system_unitdir}/usb-gadget.target.wants/
	ln -sf ../usb-gadget-eth@.service ${D}${systemd_system_unitdir}/usb-gadget.target.wants/usb-gadget-eth@${USB_PORT1}.service
	ln -sf ../usb-gadget-mtp@.service ${D}${systemd_system_unitdir}/usb-gadget.target.wants/usb-gadget-mtp@${USB_PORT1}.service
	ln -sf ../usb-gadget-uuc@.service ${D}${systemd_system_unitdir}/usb-gadget.target.wants/usb-gadget-uuc@${USB_PORT1}.service
	ln -sf ../usb-gadget-eth@.service ${D}${systemd_system_unitdir}/usb-gadget.target.wants/usb-gadget-eth@${USB_PORT2}.service
	ln -sf ../usb-gadget-mtp@.service ${D}${systemd_system_unitdir}/usb-gadget.target.wants/usb-gadget-mtp@${USB_PORT2}.service
	ln -sf ../usb-gadget-uuc@.service ${D}${systemd_system_unitdir}/usb-gadget.target.wants/usb-gadget-uuc@${USB_PORT2}.service
}

PACKAGES += " \
	${PN}-eth1 \
	${PN}-mtp1 \
	${PN}-uuc1 \
	${PN}-eth2 \
	${PN}-mtp2 \
	${PN}-uuc2 \
"

PACKAGE_ARCH = "${MACHINE_ARCH}"

RDEPENDS:${PN}-eth1 = "${PN}"
RDEPENDS:${PN}-eth2 = "${PN}"
RDEPENDS:${PN}-mtp1 = "${PN} umtp-responder"
RDEPENDS:${PN}-mtp2 = "${PN} umtp-responder"
RDEPENDS:${PN}-uuc1 = "${PN} imx-uuc"
RDEPENDS:${PN}-uuc2 = "${PN} imx-uuc"

FILES:${PN} += "${sbindir} ${systemd_system_unitdir}/*.service"
FILES:${PN}-eth1 = "${systemd_system_unitdir}/usb-gadget.target.wants/usb-gadget-eth@${USB_PORT1}.service"
FILES:${PN}-eth2 = "${systemd_system_unitdir}/usb-gadget.target.wants/usb-gadget-eth@${USB_PORT2}.service"
FILES:${PN}-mtp1 = "${systemd_system_unitdir}/usb-gadget.target.wants/usb-gadget-mtp@${USB_PORT1}.service"
FILES:${PN}-mtp2 = "${systemd_system_unitdir}/usb-gadget.target.wants/usb-gadget-mtp@${USB_PORT2}.service"
FILES:${PN}-uuc1 = "${systemd_system_unitdir}/usb-gadget.target.wants/usb-gadget-uuc@${USB_PORT1}.service"
FILES:${PN}-uuc2 = "${systemd_system_unitdir}/usb-gadget.target.wants/usb-gadget-uuc@${USB_PORT2}.service"

