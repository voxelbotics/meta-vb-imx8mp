#!/bin/sh

. sources/meta-imx/tools/imx-setup-release.sh

if ! grep -q "meta-vb-imx8mp" conf/bblayers.conf; then
	# Add navq+ BSP meta layer
	echo "BBLAYERS += \"\${BSPDIR}/sources/meta-vb-imx8mp\"" >> conf/bblayers.conf

	# Old releases can have no swupdate
	[ -d ../sources/meta-swupdate ] && \
		echo "BBLAYERS += \"\${BSPDIR}/sources/meta-swupdate\"" >> conf/bblayers.conf

	# check if linux revision must be bound
	linux_rev=$(repo forall meta-vb-imx8mp -c 'echo $REPO__linux_rev')
	[ -n "$linux_rev" ] && echo "SRCREV:pn-linux-imx = \"$linux_rev\"" >> conf/site.conf

	# check if u-boot revision must be bound
	uboot_rev=$(repo forall meta-vb-imx8mp -c 'echo $REPO__uboot_rev')
	[ -n "$uboot_rev" ] && echo "SRCREV:pn-u-boot-imx = \"$uboot_rev\"" >> conf/site.conf

	BBMASK=" imx-image-desktop "
	echo "BBMASK += \"$BBMASK\"" >> conf/local.conf
fi
