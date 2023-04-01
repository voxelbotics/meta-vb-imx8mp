#
# NAVQ+ EMMC/SD partitioning schemas
#
# Fixed single boot schema:
# 1. boot fixed size partition
# 2. rootfs fixed size partition
# 3. data fixed size partition
#
# Fixed multi boot schema:
# 1. boot fixed size partition #1
# 2. rootfs fixed size partition #1
# 3. boot fixed size partition #2
# 4. rootfs fixed size partition #2
# 5. data fixed size partition

# The supported partitioning schema names:
# - "navqplus-fixed"
# - "navqplus-fixed-multiboot"

NAVQPLUS_PARTITION_SCHEMA ?= "navqplus-fixed"

# Allow overriding default WKS file for NAVQ+
NAVQPLUS_DEFAULT_WKS ?= "${NAVQPLUS_PARTITION_SCHEMA}.wks.in"

# WKS file to create SD image
WKS_FILE = "${NAVQPLUS_DEFAULT_WKS}"

# UUU script to programm EMMC
NAVQPLUS_MFGTOOL_SCRIPT ?= "wic/${NAVQPLUS_PARTITION_SCHEMA}.uuu.in"
NAVQPLUS_MFGTOOL_KERNEL ?= "${KERNEL_IMAGETYPE}"
NAVQPLUS_MFGTOOL_DEVICETREE ?= "${KERNEL_DEVICETREE_BASENAME}.dtb"
NAVQPLUS_MFGTOOL_INITRD ?= "navqplus-install-initrd.uImage"

# sfdisk parititons used by the UUU script
NAVQPLUS_SFDISK_PARTS ?= "wic/${NAVQPLUS_PARTITION_SCHEMA}.sfdisk.in"

# Default parition sizes
BOOT_PARTITION_SIZE ?= "128M"
ROOTFS_PARTITION_SIZE ?= "10G"
DATA_PARTITION_SIZE ?= "4G"

# NOTE: we remove --no-fstab-update argument which was specified
# in imx-base.inc to auto-update fstab
# this woud auto-generate fstab entries for partitions
WIC_CREATE_EXTRA_ARGS = ""

# specify bundle expected by the mfgtool script
MFGBUNDLE_MAP ?= " \
        ${NAVQPLUS_MFGTOOL_SCRIPT}:uuu.auto \
        imx-boot:flash.bin \
        ${NAVQPLUS_MFGTOOL_KERNEL}:navqplus-mfgtool.kernel \
        ${NAVQPLUS_MFGTOOL_DEVICETREE}:navqplus-mfgtool.dtb \
        ${NAVQPLUS_MFGTOOL_INITRD}:navqplus-mfgtool.initrd \
        ${NAVQPLUS_SFDISK_PARTS}:partitions.sfdisk \
        ${WORKDIR}/build-wic/fstab:fstab \
        ${IMAGE_LINK_NAME}.tar.bz2:rootfs.tar.bz2 \
"

# specify mfgtool kernel and initrd recipes
MFGBUNDLE_KERNEL ?= "virtual/kernel"
MFGBUNDLE_INITRD ?= "navqplus-install"

# generate mfgtool bundle
inherit navqplus-mfgbundle
