PN = "otbr"
SUMMARY = "OTBR on i.MX boards"
DESCRIPTION = "OTBR applications"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://LICENSE;md5=87109e44b2fda96a8991f27684a7349c"

PATCHTOOL = "git"

SYSTEMD_AUTO_ENABLE = "disable"

S = "${WORKDIR}/git"
FILES:${PN} += "lib/systemd"
FILES:${PN} += "usr/share"
FILES:${PN} += "usr/lib"

DEPENDS += " jsoncpp avahi boost pkgconfig-native mdns libnetfilter-queue ipset libnftnl nftables "
RDEPENDS:${PN} += " jsoncpp libnetfilter-queue ipset libnftnl nftables bash "

inherit cmake

include ot_otbr_src_rev_opts_patches_certification.inc

EXTRA_OECMAKE += "-DOT_POSIX_CONFIG_RCP_BUS=UART"
