# Copyright (C) 2022 Voxelbotics

DESCRIPTION = "Small initramfs for manufacturing of secure-boot enabled i.MX 8M boards"
LICENSE = "MIT"

NAVQ_ROOTFS_ARCHIVE = "imx-image-desktop-imx8mpnavq.tar.bz2"
COMPATIBLE_HOST = "(aarch64-fsl).*-linux"
SCRIPT_NAME = "navq-install-desktop"
include navq-install.bb
