# Copyrigh (C) 2022 Voxelbotics
DESCRIPTION = "NAVQ+ rootfs image"
SECTION = ""

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

IMAGE_FSTYPES = "tar.bz2 wic.bz2"

include recipes-core/images/core-image-minimal.bb

IMAGE_FEATURES += "			\
    package-management			\
"

IMAGE_INSTALL:append = "		\
    navq-swu-scripts			\
    navq-wpa-supplicant		\
    usb-gadgets-mtp1			\
    openssh				\
    ${@bb.utils.contains('PACKAGE_CLASSES', 'package_ipk', 'opkg', '', d)} \
    ${@bb.utils.contains('PACKAGE_CLASSES', 'package_rpm', 'rpm', '', d)} \
"

FEATURE_PACKAGES_navq-swupdate = "	\
    swupdate				\
    e2fsprogs				\
    dosfstools				\
    libgcc				\
    u-boot-imx-env			\
    libubootenv-bin			\
    libubootenv				\
"

WKS_FILE := " ${@bb.utils.contains('EXTRA_IMAGE_FEATURES', 'navq-swupdate', 'imx8mpnavq-emmc-swupdate-minimal.wks.in', '${WKS_FILE}', d)}"
