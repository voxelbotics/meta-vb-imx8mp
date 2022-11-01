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
# - "navq-fixed"
# - "navq-fixed-multiboot"

NAVQ_PARTITION_SCHEMA ?= "navq-fixed"

# Allow overriding default WKS file for NAVQ+
NAVQ_DEFAULT_WKS ?= "${NAVQ_PARTITION_SCHEMA}.wks.in"

# WKS file to create SD image
WKS_FILE = "${NAVQ_DEFAULT_WKS}"

# UUU script to programm EMMC
NAVQ_MFGTOOL_SCRIPT ?= "wic/${NAVQ_PARTITION_SCHEMA}.uuu.in"
NAVQ_MFGTOOL_KERNEL ?= "${KERNEL_IMAGETYPE}"
NAVQ_MFGTOOL_DEVICETREE ?= "${KERNEL_DEVICETREE_BASENAME}.dtb"
NAVQ_MFGTOOL_INITRD ?= "navq-install-initrd.uImage"

# sfdisk parititons used by the UUU script
NAVQ_SFDISK_PARTS ?= "wic/${NAVQ_PARTITION_SCHEMA}.sfdisk.in"

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
        ${NAVQ_MFGTOOL_SCRIPT}:uuu.auto \
        imx-boot:flash.bin \
        ${NAVQ_MFGTOOL_KERNEL}:navq-mfgtool.kernel \
        ${NAVQ_MFGTOOL_DEVICETREE}:navq-mfgtool.dtb \
        ${NAVQ_MFGTOOL_INITRD}:navq-mfgtool.initrd \
        ${NAVQ_SFDISK_PARTS}:partitions.sfdisk \
        ${WORKDIR}/build-wic/fstab:fstab \
        ${IMAGE_LINK_NAME}.tar.bz2:rootfs.tar.bz2 \
"

# specify mfgtool kernel and initrd recipes
MFGBUNDLE_KERNEL ?= "virtual/kernel"
MFGBUNDLE_INITRD ?= "navq-install"

# generate mfgtool bundle
inherit navq-mfgbundle
