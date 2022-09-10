FILESEXTRAPATHS:prepend := "${THISDIR}/u-boot-imx:"

SRC_URI = "git://git@gitlab.com/VoxelBotics/u-boot-imx.git;protocol=ssh;branch=imx-5.15.32-vb"

SRCREV = "${AUTOREV}"
