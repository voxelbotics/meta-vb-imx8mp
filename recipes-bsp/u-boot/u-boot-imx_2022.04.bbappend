FILESEXTRAPATHS:prepend := "${THISDIR}/u-boot-imx:"

SRC_URI = "git://github.com/voxelbotics/u-boot-imx.git;protocol=https;branch=imx-5.15.32-vb;nobranch=1"

SRCREV = "${AUTOREV}"
