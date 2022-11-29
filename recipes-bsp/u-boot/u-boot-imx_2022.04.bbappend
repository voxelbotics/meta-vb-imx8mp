FILESEXTRAPATHS:prepend := "${THISDIR}/u-boot-imx:"

SRC_URI = "git://github.com/voxelbotics/u-boot-imx.git;protocol=https;branch=imx-5.15.32-vb"

SRCREV = "${AUTOREV}"
LOCALVERSION = "-head-11261511-2ac604d11b"
