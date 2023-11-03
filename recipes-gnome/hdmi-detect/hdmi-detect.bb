# Copyrigh (C) 2023 VoxelBotics
# A service to detect HDMI link

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = " \
	file://hdmi-detect.conf \
	file://hdmi-detect.service \
	file://hdmi-detect.sh \
	file://hdmi-hotplug.rules \
	file://hdmi-hotplug.sh \
"

inherit allarch systemd

do_install() {
	install -d ${D}

	install -d ${D}${sysconfdir}/udev/rules.d
	install -m 0644 ${WORKDIR}/hdmi-hotplug.rules ${D}${sysconfdir}/udev/rules.d/50-hdmi-hotplug.rules

	install -d ${D}${datadir}/${BPN}
	install -m 0755 ${WORKDIR}/hdmi-detect.sh ${D}${datadir}/${BPN}
	install -m 0755 ${WORKDIR}/hdmi-hotplug.sh ${D}${datadir}/${BPN}

	install -d ${D}${systemd_system_unitdir}
	install -m 0644 ${WORKDIR}/hdmi-detect.service ${D}${systemd_system_unitdir}

	install -d ${D}${systemd_system_unitdir}/gdm.service.d
	install -m 0644 ${WORKDIR}/hdmi-detect.conf  ${D}${systemd_system_unitdir}/gdm.service.d/50-hdmi-detect.conf
}

SYSTEMD_SERVICE:${PN} = "hdmi-detect.service"
FILES:${PN} += "${systemd_system_unitdir}"
