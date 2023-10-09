# Copyrigh (C) 2023 VoxelBotics
# NavQ+ persistent storage scripts

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = " \
	file://navq-network-settings.path \
	file://navq-network-settings.service \
	file://navq-persistent-storage.service \
	file://network-settings.sh \
	file://setup-storage.sh \
"

inherit allarch systemd

do_install() {
	install -d ${D}

	install -d ${D}${datadir}/${BPN}
	install -m 0755 ${WORKDIR}/setup-storage.sh ${D}${datadir}/${BPN}
	install -d ${D}${datadir}/${BPN}/storage-scripts.d
	# NOTE: drop script extension which is needed for run-parts to work
	install -m 0755 ${WORKDIR}/network-settings.sh ${D}${datadir}/${BPN}/storage-scripts.d/network-settings

	install -d ${D}${systemd_system_unitdir}
	install -m 0644 ${WORKDIR}/navq-network-settings.path ${D}${systemd_system_unitdir}
	install -m 0644 ${WORKDIR}/navq-network-settings.service ${D}${systemd_system_unitdir}
	install -m 0644 ${WORKDIR}/navq-persistent-storage.service ${D}${systemd_system_unitdir}
}

SYSTEMD_SERVICE:${PN} = " \
	navq-network-settings.path \
	navq-network-settings.service \
	navq-persistent-storage.service \
	"
