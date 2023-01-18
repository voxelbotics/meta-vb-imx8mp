
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

do_install:append () {
    perl -pi -e "s/fw_name=nxp\/sdiouart8987_combo_v0.bin/ext_scan=1\n\tdrv_mode=1\n\tfw_name=nxp\/sdiouart8987_combo_v0.bin/" ${D}${nonarch_base_libdir}/firmware/nxp/wifi_mod_para.conf
}
