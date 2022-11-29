FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI = "git://github.com/voxelbotics/linux-imx.git;protocol=https;branch=imx-5.15.32-vb"
SRCREV = "${AUTOREV}"

SRC_URI += " \
    file://cp21xx.cfg \
    file://ov5645tn.cfg \
    file://tja1xxc45.cfg \
    file://pcf2131.cfg \
    file://gasket_apex.cfg \
"

do_configure:append () {
    ${S}/scripts/kconfig/merge_config.sh -m -O ${B} ${B}/.config $(ls ${WORKDIR}/*.cfg)
}
LOCALVERSION = "-head-11261511-2ac604d11b"
