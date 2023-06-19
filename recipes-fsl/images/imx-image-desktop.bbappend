require imx-image.inc
IMAGE_PREPROCESS_COMMAND:remove = "do_fix_connman_conflict;"
APTGET_EXTRA_PACKAGES:remove = "connman"

APTGET_EXTRA_PACKAGES += " \
		       iw   \
		       usbutils	\
		       ${@bb.utils.contains('PACKAGE_CLASSES', 'package_rpm', 'rpm', '', d)} \
		       "

ROOTFS_POSTPROCESS_COMMAND:append = "do_enable_gdm_autologin; do_config_gnome;"

DEPENDS:append = " dconf-native"

do_enable_gdm_autologin () {
    # Enable gdm auto-login
    sed -i "s/#  AutomaticLoginEnable = true/AutomaticLoginEnable = true/" ${IMAGE_ROOTFS}/etc/gdm3/custom.conf
    sed -i "s/#  AutomaticLogin = user1/AutomaticLogin = user/" ${IMAGE_ROOTFS}/etc/gdm3/custom.conf
}

fakeroot do_config_gnome () {
    set -x

    install -d ${IMAGE_ROOTFS}${sysconfdir}/dconf/profile
    echo "user-db:user" > ${IMAGE_ROOTFS}${sysconfdir}/dconf/profile/user
    echo "system-db:local" >> ${IMAGE_ROOTFS}${sysconfdir}/dconf/profile/user

    install -d ${IMAGE_ROOTFS}${sysconfdir}/dconf/db/local.d
    echo "[org/gnome/desktop/screensaver]" > ${IMAGE_ROOTFS}${sysconfdir}/dconf/db/local.d/00-gnome-config
    echo -e "lock-enabled=false\n" >> ${IMAGE_ROOTFS}${sysconfdir}/dconf/db/local.d/00-gnome-config
    echo "[org/gnome/settings-daemon/plugins/power]" >> ${IMAGE_ROOTFS}${sysconfdir}/dconf/db/local.d/00-gnome-config
    echo -e "sleep-inactive-ac-type='nothing'\n" >> ${IMAGE_ROOTFS}${sysconfdir}/dconf/db/local.d/00-gnome-config
    echo "[org/gnome/desktop/session]" >> ${IMAGE_ROOTFS}${sysconfdir}/dconf/db/local.d/00-gnome-config
    echo -e "idle-delay=uint32 0\n" >> ${IMAGE_ROOTFS}${sysconfdir}/dconf/db/local.d/00-gnome-config
    echo "[org/gnome/shell]" >> ${IMAGE_ROOTFS}${sysconfdir}/dconf/db/local.d/00-gnome-config
    echo "enabled-extensions=['no-overview@fthx']" >> ${IMAGE_ROOTFS}${sysconfdir}/dconf/db/local.d/00-gnome-config

    dconf update ${IMAGE_ROOTFS}${sysconfdir}/dconf/db

    set +x
}

IMAGE_INSTALL += " \
		navq-wpa-supplicant \
		umtp-responder \
		usb-gadgets \
"
