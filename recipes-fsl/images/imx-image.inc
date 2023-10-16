ROOTFS_POSTPROCESS_COMMAND += "custom_files; "
CUSTOM_FILES_PATH := "${THISDIR}/files"

custom_files() {
	install -m 0644 ${CUSTOM_FILES_PATH}/vb-release ${IMAGE_ROOTFS}${sysconfdir}/
}

do_enable_graphics:append() {
	#remove dependency on X11 gnome-session
	sed -i 's/\(Wants=org.gnome.SettingsDaemon.XSettings.target\)/#\1/' ${IMAGE_ROOTFS}/lib/systemd/user/gnome-session@gnome.target.d/gnome.session.conf
	sed -i 's/\(Wants=org.gnome.SettingsDaemon.XSettings.target\)/#\1/' ${IMAGE_ROOTFS}/lib/systemd/user/gnome-session@gnome-login.target.d/session.conf
	sed -i 's/\(Wants=org.gnome.Shell@x11.service\)/#\1/' ${IMAGE_ROOTFS}/lib/systemd/user/org.gnome.Shell.target
	sed -i 's/\(#WaylandEnable=false\)/\1\nXorgEnable=false/' ${IMAGE_ROOTFS}/etc/gdm3/custom.conf
}
