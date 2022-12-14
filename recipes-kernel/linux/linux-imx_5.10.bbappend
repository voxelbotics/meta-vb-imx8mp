FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI = "git://git@gitlab.com/VoxelBotics/linux-imx.git;protocol=ssh;branch=imx-5.10.72-vb"
SRCREV = "${AUTOREV}"

SRC_URI += " \
    file://cp21xx.cfg \
    file://ov5645tn.cfg \
    file://tja1xxc45.cfg \
    file://pcf2131.cfg \
    file://gasket_apex.cfg \ 
"

do_configure:append () {
    ${S}/scripts/kconfig/merge_config.sh -m -O ${WORKDIR}/build ${WORKDIR}/build/.config ${WORKDIR}/*.cfg
}
