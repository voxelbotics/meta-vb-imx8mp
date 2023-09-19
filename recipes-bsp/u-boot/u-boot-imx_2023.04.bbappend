FILESEXTRAPATHS:prepend := "${THISDIR}/u-boot-imx:"

SRC_URI = "git://github.com/voxelbotics/u-boot-imx.git;protocol=https;branch=imx-6.1.22-vb;nobranch=1"

SRCREV = "${AUTOREV}"
# NOTE: this fixes release build with the overridden SRCREV in site.conf
PV = "2023.04-${SRCPV}"
