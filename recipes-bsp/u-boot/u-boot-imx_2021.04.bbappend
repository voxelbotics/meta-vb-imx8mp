FILESEXTRAPATHS_prepend := "${THISDIR}/u-boot-imx:"

SRC_URI += " \
    file://0001-imx8mpnavq-linux-dtb.patch \
    file://0002-imx8mpnavq-uboot-changes.patch \
    file://0003-imx8mpnavq-3vp-5vp-enable.patch \
    file://0004-imx8mpnavq-fixed-tcpc-config.patch \
"

SRCREV = "3463140881c523e248d2fcb6bfc9ed25c0db93bd"
