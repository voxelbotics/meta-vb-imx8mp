FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI += "file://sources.list"

do_install:append() {
	install -m 644 ${WORKDIR}/sources.list ${D}${sysconfdir}/apt
}
