ROOTFS_POSTPROCESS_COMMAND += "custom_files; "
CUSTOM_FILES_PATH := "${THISDIR}/files"

custom_files() {
	install -m 0644 ${CUSTOM_FILES_PATH}/vb-release ${IMAGE_ROOTFS}${sysconfdir}/
	install -m 0755 ${CUSTOM_FILES_PATH}/btinit.sh ${IMAGE_ROOTFS}/usr/bin/
}
