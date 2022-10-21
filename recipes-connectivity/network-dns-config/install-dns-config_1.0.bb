DESCRIPTION = "Install DNS configuration for NetworkManager"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = " \
	file://90-dns-none.conf \
"

S = "${WORKDIR}"

do_install() {

	install -d ${D}/etc/NetworkManager/conf.d
	install -m 0644 ${S}/90-dns-none.conf ${D}/etc/NetworkManager/conf.d

}

FILES_${PN} = "/etc/NetworkManager/conf.d"
