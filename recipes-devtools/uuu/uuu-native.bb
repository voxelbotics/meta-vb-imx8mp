# Copyright (C) 2022 Voxelbotics
# Build the NXP UUU tool and install it to the images directory

SRC_URI = "git://github.com/codeauroraforum/mfgtools.git;protocol=https;branch=master"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://LICENSE;md5=38ec0c18112e9a92cffc4951661e85a5"

S = "${WORKDIR}/git"
SRCREV = "uuu_1.4.237"
PV = "1.4.237+git${SRCPV}"

DEPENDS = "libusb1-native libzip-native"

inherit cmake native

EXTRA_OECMAKE += "-DSTATIC=1"
# We need an exportable binary, don't hardcode dynlinker path.
BUILD_LDFLAGS:remove = "-Wl,--dynamic-linker=${UNINATIVE_LOADER}"

addtask deploy after do_install

do_deploy () {
	   install -d ${DEPLOY_DIR_IMAGE}
	   install -m 0755 ${B}/uuu/uuu  ${DEPLOY_DIR_IMAGE}
}
