# Copyrigh (C) 2022 Voxelbotics
DESCRIPTION = "NAVQ+ upgrade image in SWU format"
SECTION = ""

LICENSE = "MIT"

# Add all local files to be added to the SWU
# sw-description must always be in the list.
# You can extend with scripts or whatever you need
SRC_URI = " \
    file://sw-description \
"

SWU_VERSION = "${NAVQ_DISTRO_VERSION}"

SWU_ROOTFS = "navq-rootfs"

SWU_ROOTFS_FILE = "${SWU_ROOTFS}-${MACHINE}.tar.bz2"
SWU_UBOOT_FILE = "imx-boot"
SWU_KERNEL_FILE = "Image"
SWU_DTB_FILE = "${KERNEL_DEVICETREE_BASENAME}.dtb"

# images to build before building swupdate image
IMAGE_DEPENDS = "navq-rootfs imx-boot linux-imx"

# images and files that will be included in the 1.swu image
SWUPDATE_IMAGES = "${SWU_ROOTFS} ${SWU_UBOOT_FILE} ${SWU_KERNEL_FILE} ${SWU_DTB_FILE}"

# a deployable image can have multiple format, choose one
SWUPDATE_IMAGES_FSTYPES[navq-rootfs] = "-${MACHINE}.tar.bz2"

inherit swupdate
