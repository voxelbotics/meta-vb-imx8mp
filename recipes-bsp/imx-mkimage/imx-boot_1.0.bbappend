# A trick to make imx-mkimage to use the correct DTB

do_compile_prepend_mx8mpsom () {
    if [ "${SOC_TARGET}" = "iMX8MP" ]; then
        echo "Copying ${UBOOT_DTB_NAME} as imx8mp-evk.dtb"
	cp ${DEPLOY_DIR_IMAGE}/${BOOT_TOOLS}/${UBOOT_DTB_NAME}   ${BOOT_STAGING}/imx8mp-evk.dtb
	cp ${DEPLOY_DIR_IMAGE}/${BOOT_TOOLS}/${UBOOT_DTB_NAME}   ${BOOT_STAGING}/evk.dtb
    fi
}
