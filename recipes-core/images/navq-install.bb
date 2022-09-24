# Copyright (C) 2022 Voxelbotics

DESCRIPTION = "Small initramfs for manufacturing of secure-boot enabled i.MX 8M boards"
LICENSE = "CLOSED"

NAVQ_ROOTFS_ARCHIVE ??= "imx-image-full-imx8mpnavq.tar.bz2"
BOOT_PARTION_SIZE ??= "128M"
ROOTFS_PARTION_SIZE ??= "5G"

DEPENDS += " u-boot-mkimage-native "

INITRAMFS_SCRIPTS ?= ""

PACKAGE_INSTALL = " \
		${INITRAMFS_SCRIPTS} \
		${VIRTUAL-RUNTIME_base-utils} \
		coreutils \
		udev \
		base-passwd \
		systemd-initramfs \
		imx-uuc \
		dosfstools \
		e2fsprogs-mke2fs \
		util-linux \
		navq-files \
		${ROOTFS_BOOTSTRAP_INSTALL}"

export IMAGE_BASENAME = "${MLPREFIX}navq-install-initrd"
IMAGE_LINGUAS = ""

IMAGE_FSTYPES = "${INITRAMFS_FSTYPES}"
inherit core-image

IMAGE_ROOTFS_SIZE = "16384"
IMAGE_ROOTFS_EXTRA_SPACE = "0"

COMPATIBLE_HOST ?= "aarch64-.*-linux"
SCRIPT_NAME ?= "navq-install"

#ROOTFS_POSTPROCESS_COMMAND += " custom_files; "
IMAGE_POSTPROCESS_COMMAND += " build_uimage; "

build_uimage() {
	mkimage -n 'Secure Boot Install' -A arm -O linux -T ramdisk -C gzip -d ${IMGDEPLOYDIR}/${IMAGE_NAME}.rootfs.cpio.gz ${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.uImage
	ln -sf ${IMAGE_NAME}.uImage ${DEPLOY_DIR_IMAGE}/${IMAGE_BASENAME}.uImage

	# generate partition table script
	cat << EOF > ${DEPLOY_DIR_IMAGE}/partitions.sfdisk
label: gpt

/dev/mmcblk2p1 : start=16384, size=${BOOT_PARTION_SIZE}, type=L, name="boot1"
/dev/mmcblk2p2 : size=${BOOT_PARTION_SIZE}, type=L, name="boot2"
/dev/mmcblk2p3 : size=${ROOTFS_PARTION_SIZE}, type=L, name="rootfs1"
/dev/mmcblk2p4 : size=${ROOTFS_PARTION_SIZE}, type=L, name="rootfs2"
/dev/mmcblk2p5 : type=L, name="data"
EOF
	# generate uuu script
	cat << EOF > ${DEPLOY_DIR_IMAGE}/${SCRIPT_NAME}.uuu
uuu_version 1.0.1

# boot installation initrd image
SDPS: boot -f imx-boot-imx8mpnavq-sd.bin-flash_evk
FB: ucmd setenv fastboot_buffer \$loadaddr
FB: download -f Image
FB: ucmd setenv fastboot_buffer \$fdt_addr
FB: download -f imx8mp-navq.dtb
FB: ucmd setenv fastboot_buffer \$initrd_addr
FB: download -f navq-install-initrd.uImage
FB: ucmd run mmcargs
FB: ucmd setenv bootargs $bootargs quiet=quiet mfgboot
FB: acmd booti \$loadaddr \$initrd_addr \$fdt_addr

# upload and install boot and rootfs images
FBK: ucp imx-boot-imx8mpnavq-sd.bin-flash_evk T:/tmp/imx-boot-imx8mpnavq-sd.bin-flash_evk
FBK: ucmd dd if=/tmp/imx-boot-imx8mpnavq-sd.bin-flash_evk of=/dev/mmcblk2 bs=1k seek=32
FBK: ucp partitions.sfdisk T:/tmp/partitions.sfdisk
FBK: ucmd (ls /dev/mmcblk2?* | xargs umount) || true
FBK: ucmd sfdisk /dev/mmcblk2 < /tmp/partitions.sfdisk
FBK: ucmd mkfs.vfat /dev/mmcblk2p1
FBK: ucmd mount /dev/mmcblk2p1 /mnt
FBK: ucp Image T:/mnt/Image
FBK: ucp imx8mp-navq.dtb T:/mnt/imx8mp-navq.dtb
FBK: ucmd umount /mnt
FBK: ucmd mkfs.ext4 -F /dev/mmcblk2p3
FBK: ucmd mount /dev/mmcblk2p3 /mnt
FBK: acmd tar jx -C /mnt
FBK: ucp ${NAVQ_ROOTFS_ARCHIVE} T:-
FBK: sync
FBK: ucmd mkdir -p /mnt/data
FBK: ucmd mount /dev/mmcblk2p5 /mnt/data || (mkfs.ext4 /dev/mmcblk2p5 && mount /dev/mmcblk2p5 /mnt/data)
FBK: ucmd test -f /mnt/data/etc/wpa_supplicant/wpa_supplicant-mlan0.conf || test -f /mnt/etc/wpa_supplicant.conf && (mkdir -p /mnt/data/etc/wpa_supplicant && cp -a /mnt/etc/wpa_supplicant.conf /mnt/data/etc/wpa_supplicant/wpa_supplicant-mlan0.conf) || true
FBK: ucmd umount /mnt/data
FBK: ucmd umount /mnt
FBK: done
EOF
}
