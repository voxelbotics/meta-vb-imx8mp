#!/bin/bash
set -x

BUILD_DESKTOP="yes"
SETTAG="HEAD"
BRANCH=imx-5.15.5-vb


while getopts "k:it:c:" opt; do
	case "$opt" in
		i) BUILD_DESKTOP="no"
			;;
		k) SSHKEY=$OPTARG
			;;
		t) SETTAG=$OPTARG
			;;
		c) DST=$OPTARG
			;;
	esac
done

if [ x"$BUILD_DESKTOP" = "xyes" ]; then
    MANIFEST="imx-5.15.5-1.0.0_desktop.xml"
    DISTRO="imx-desktop-xwayland"
    SETUP="imx-setup-desktop.sh"
    IMGNAME="imx-image-desktop"
    BUILDRECIPES="imx-image-desktop navqplus-install-desktop"
    BUILDDIR="build-desktop"
    BBMASK=""
else
    MANIFEST="imx-5.15.5-1.0.0.xml"
    DISTRO="fsl-imx-xwayland"
    IMGNAME="imx-image-full"
    BUILDRECIPES="imx-image-full navqplus-install"
    SETUP="imx-setup-release.sh"
    BUILDDIR="build-image"
    BBMASK=" imx-image-desktop "
fi

function cleanup() {
	eval $(ssh-agent -k)
}

if [ -f "$SSHKEY" ]; then
	eval $(ssh-agent)
	ssh-add $SSHKEY
	trap cleanup EXIT
fi

# make sure cache writes have w other access
# see also BB_DEFAULT_UMASK below
# umask 0000
umask 0002

PATCHES=/home/build/patches/5.15.5-1.0.0

BUILD=`date +%Y%m%d.%H%M`; start=`date +%s`
#git config --global user.email "kent@emcraft.com"
#git config --global user.name "Kent Meyer"


mkdir -p $BUILDDIR
cd $BUILDDIR

repo init -u https://source.codeaurora.org/external/imx/imx-manifest -b imx-linux-honister -m ${MANIFEST} || exit $?
repo sync || exit $?

# allow build to not prompt for input
sed 's/more\ -d/\#more\ -d/' setup-environment > x && mv -f x setup-environment || exit $?

get_yocto_hash() {
	local githash=$(git rev-parse --short=10 HEAD)
	echo "$githash"
}

get_yocto_info() {
	local githash=$(get_yocto_hash)
	local val=$(echo "yocto-distro aarch64 x.x.x+git0+$githash-r0")
	echo "$val"
}

mkdir tmp
pushd tmp
if [ "$SETTAG" != "HEAD" ]; then
	git clone -b $BRANCH git@gitlab.com:VoxelBotics/u-boot-imx.git || exit $?
	git clone -b $BRANCH git@gitlab.com:VoxelBotics/linux-imx.git || exit $?
	for i in u-boot-imx linux-imx; do
		pushd $i
		if [ -z $(git tag -l $SETTAG) ]; then
			echo "Set tag $SETTAG to $i"
			git tag $SETTAG || exit $?
			git push origin $SETTAG || exit $?
		fi
		popd
	done
fi
popd

pushd sources
git clone -b $BRANCH git@gitlab.com:VoxelBotics/meta-vb-imx8mp.git || exit $?
pushd meta-vb-imx8mp
yocto_hash=$(get_yocto_hash)
yocto_info=$(get_yocto_info)
if [ "$SETTAG" != "HEAD" ]; then
	if [ -z $(git tag -l $SETTAG) ]; then
		echo "Set tag $SETTAG"
		git tag $SETTAG || exit $?
		git push origin $SETTAG || exit $?
	else
		git checkout $SETTAG
	fi
	echo "Building $SETTAG"
else
	echo "Building HEAD"
fi
popd
popd
RELEASE_VER="${SETTAG}_$(date +%m%d%H%M)-${yocto_hash}"


DISTRO=${DISTRO} MACHINE=navqplus EULA=yes BUILD_DIR=builddir source ./${SETUP} || exit $?

sed -i 's/^DL_DIR.*$/DL_DIR\ \?=\ \"\/home\/cache\/CACHE\/5.15.5\/downloads\/\"/' conf/local.conf || exit $?
echo "SSTATE_DIR = \"/home/cache/CACHE/5.15.5/sstate-cache\"" >> conf/local.conf || exit $?
echo "IMAGE_INSTALL:append = \" navqplus-files \"" >> conf/local.conf || exit $?
echo "BBMASK += \"$BBMASK\"" >> conf/local.conf || exit $?
echo "BB_DEFAULT_UMASK = \"0002\"" >> conf/local.conf || exit $?
sed -i -e "s/BB_DEFAULT_UMASK =/BB_DEFAULT_UMASK ?=/" ../sources/poky/meta/conf/bitbake.conf

echo BBLAYERS += \"\${BSPDIR}/sources/meta-vb-imx8mp\" >> conf/bblayers.conf || exit $?

echo $RELEASE_VER > ${BUILDDIR}/../sources/meta-vb-imx8mp/recipes-fsl/images/files/vb-release || exit $?
echo "LOCALVERSION = \"-$RELEASE_VER\"" >> ${BUILDDIR}/../sources/meta-vb-imx8mp/recipes-bsp/u-boot/u-boot-imx_2021.04.bbappend || exit $?
echo "LOCALVERSION = \"-$RELEASE_VER\"" >> ${BUILDDIR}/../sources/meta-vb-imx8mp/recipes-kernel/linux/linux-imx_5.15.bbappend || exit $?

if [ "$SETTAG" != "HEAD" ]; then
	echo "SRCREV:pn-u-boot-imx = \"$SETTAG\"" >> conf/site.conf
	echo "SRCREV:pn-linux-imx = \"$SETTAG\"" >> conf/site.conf
fi

#devtool modify u-boot-imx
#devtool modify linux-imx

bitbake ${BUILDRECIPES} uuu-native || exit $?

echo "$yocto_info" >> $BUILDDIR/tmp/deploy/images/navqplus/$IMGNAME-navqplus.manifest || exit $?

files=(
	Image
	navqplus.dtb
	imx-boot-navqplus-sd.bin-flash_evk
	imx-image-desktop-navqplus.tar.bz2
	imx-image-desktop-navqplus.wic.bz2
	imx-image-full-navqplus.tar.bz2
	imx-image-full-navqplus.wic.bz2
	navqplus-dbg.uuu
	navqplus-install-desktop.uuu
	navqplus-install.uuu
	navqplus-install-initrd.uImage
	partitions.sfdisk
)

# copy artifacts
if [ -d "$DST" ]; then
	mkdir -p $DST/$RELEASE_VER
	for i in ${files[*]}; do
		file=$BUILDDIR/tmp/deploy/images/navqplus/$i
		if [ -f $file ]; then
			cp $file $DST/$RELEASE_VER/
		fi
	done
fi

finish=`date +%s`; echo "### Build Time = `expr \( $finish - $start \) / 60` minutes"
