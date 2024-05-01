# Copyrigh (C) 2023 Voxelbotics
DESCRIPTION = "NAVQ+ ROS upgrade image in SWU format"
SECTION = ""

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

# Add all local files to be added to the SWU
# sw-description must always be in the list.
# You can extend with scripts or whatever you need
SRC_URI = " \
    file://sw-description \
"

SWU_VERSION = "${NAVQ_DISTRO_VERSION}"

SWU_ROOTFS = "imx-image-desktop-ros"
SWU_STG_DEV = "/dev/mmcblk1"

SWU_ROOTFS_FILE = "${SWU_ROOTFS}-${MACHINE}.tar.bz2"
SWU_UBOOT_FILE = "imx-boot"
SWU_KERNEL_FILE = "Image"
SWU_DTB_FILE = "${KERNEL_DEVICETREE_BASENAME}.dtb"

# images to build before building swupdate image
IMAGE_DEPENDS = "${SWU_ROOTFS} imx-boot linux-imx"

# images and files that will be included in the .swu image
SWUPDATE_IMAGES = "${SWU_ROOTFS} ${SWU_UBOOT_FILE} ${SWU_KERNEL_FILE} ${SWU_DTB_FILE}"

# a deployable image can have multiple format, choose one
SWUPDATE_IMAGES_FSTYPES[imx-image-desktop-ros] = "-${MACHINE}.tar.bz2"

inherit swupdate

python () {
    if not bb.utils.contains('EXTRA_IMAGE_FEATURES', 'navq-swupdate', True, False, d):
       bb.fatal("EXTRA_IMAGE_FEATURES must include 'navq-swupdate' for .swu build")
}
