FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI = "git://git@gitlab.com/VoxelBotics/linux-imx.git;protocol=ssh;branch=imx-5.15.32-vb"
SRCREV = "a7c2d7963acf8d631ed31b482566bc0de70b0432"

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
