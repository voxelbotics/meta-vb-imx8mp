FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

DEPENDS += "zlib openssl libubootenv"

SRC_URI += "file://defconfig"
