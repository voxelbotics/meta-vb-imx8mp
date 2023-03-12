FILESEXTRAPATHS:prepend := "${THISDIR}/u-boot-imx:"

SRC_URI = "git://github.com/voxelbotics/u-boot-imx.git;protocol=https;branch=imx-5.15.32-vb"

SRC_URI:append = " ${@bb.utils.contains('EXTRA_IMAGE_FEATURES', 'navq-swupdate', 'file://001-reliable_update_mmcroot_setup.patch', '', d)} "

SRCREV = "${AUTOREV}"
