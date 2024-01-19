FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"


SRC_URI += "file://0001-isp-imx-add-ov5647.patch"
SRC_URI += "file://0002-isp-imx-add-imx219.patch"
SRC_URI += "file://0003-isp-imx-make-ov5647-default.patch"
SRC_URI += "file://0004-isp-imx-make-imx219-default.patch"

FILES_SOLIBS_VERSIONED += " \
    ${libdir}/libimx219.so \
    ${libdir}/libov5647.so \
"
