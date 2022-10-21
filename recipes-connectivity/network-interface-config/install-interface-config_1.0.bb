DESCRIPTION = "Configure network interfaces on NavQPlus"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = " \
	file://10-usb0.network \ 
	file://10-eth.network \
	file://10-wifi.network \
	file://10-can.network \
"

S = "${WORKDIR}"

do_install() {

	install -d ${D}/etc/systemd/network
	install -m 0644 ${S}/10-usb0.network ${D}/etc/systemd/network
	install -m 0644 ${S}/10-eth.network ${D}/etc/systemd/network
	install -m 0644 ${S}/10-wifi.network ${D}/etc/systemd/network
	install -m 0644 ${S}/10-can.network ${D}/etc/systemd/network

}

FILES_${PN} = "/etc/systemd/network"
