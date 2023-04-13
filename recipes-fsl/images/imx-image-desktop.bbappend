require imx-image.inc
IMAGE_PREPROCESS_COMMAND:remove = "do_fix_connman_conflict;"
APTGET_EXTRA_PACKAGES:remove = "connman"

APTGET_EXTRA_PACKAGES += " \
		       iw   \
		       usbutils	\
		       ${@bb.utils.contains('PACKAGE_CLASSES', 'package_rpm', 'rpm', '', d)} \
		       "

ROOTFS_POSTPROCESS_COMMAND:append = "do_enable_gdm_autologin;do_fix_bt_init;"

do_enable_gdm_autologin () {
    # Enable gdm auto-login
    sed -i "s/#  AutomaticLoginEnable = true/AutomaticLoginEnable = true/" ${IMAGE_ROOTFS}/etc/gdm3/custom.conf
    sed -i "s/#  AutomaticLogin = user1/AutomaticLogin = user/" ${IMAGE_ROOTFS}/etc/gdm3/custom.conf
}

do_fix_bt_init() {
	sed -i 's/bluetoothd/bluetoothd -C -E\nExecStartPre=\/usr\/bin\/btinit.sh/'  ${IMAGE_ROOTFS}/lib/systemd/system/bluetooth.service
	sed -i 's/CAP_NET_BIND_SERVICE/CAP_NET_BIND_SERVICE CAP_NET_RAW/'  ${IMAGE_ROOTFS}/lib/systemd/system/bluetooth.service
}

IMAGE_INSTALL += " \
		navq-wpa-supplicant \
		umtp-responder \
		usb-gadgets \
"
