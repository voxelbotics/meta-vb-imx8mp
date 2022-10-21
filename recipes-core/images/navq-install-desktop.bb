# Copyright (C) 2022 Voxelbotics

DESCRIPTION = "Small initramfs for manufacturing of secure-boot enabled i.MX 8M boards"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

NAVQ_ROOTFS_ARCHIVE = "imx-image-desktop-imx8mpnavq.tar.bz2"
COMPATIBLE_HOST = "(aarch64-fsl).*-linux"
SCRIPT_NAME = "navq-install-desktop"
include navq-install.bb
