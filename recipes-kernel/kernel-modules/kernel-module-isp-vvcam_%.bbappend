FILESEXTRAPATHS:prepend := "${THISDIR}/kernel-module-isp-vvcam:"

SRC_URI += " \
	file://0001-isp-vvcam-add-ov5647.patch \
	file://0002-NAVQP-182-adjust-sensor-settings-to-output-30-FPS.patch \
	file://0003-isp-vvcam-add-imx219.patch \
	"
