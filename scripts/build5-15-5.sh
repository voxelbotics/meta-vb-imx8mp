#!/bin/bash
set -x

BUILD_DESKTOP="yes"

if [ x"$BUILD_DESKTOP" = "xyes" ]; then
    MANIFEST="imx-5.15.5-1.0.0_desktop.xml"
    DISTRO="imx-desktop-xwayland"
    SETUP="imx-setup-desktop.sh"
    BUILDRECIPE="imx-image-desktop"
else
    MANIFEST="imx-5.15.5-1.0.0.xml"
    DISTRO="fsl-imx-xwayland"
    BUILDRECIPE="imx-image-full"
    SETUP="imx-setup-release.sh"
fi


# make sure cache writes have w other access
# umask 0000
umask 0002

PATCHES=/home/build/patches/5.15.5-1.0.0

BUILD=`date +%Y%m%d.%H%M`; start=`date +%s`
#git config --global user.email "kent@emcraft.com"
#git config --global user.name "Kent Meyer"

BUILDDIR=build

mkdir -p $BUILDDIR
cd $BUILDDIR

repo init -u https://source.codeaurora.org/external/imx/imx-manifest -b imx-linux-honister -m ${MANIFEST}
repo sync

# allow build to not prompt for input
sed 's/more\ -d/\#more\ -d/' setup-environment > x && mv -f x setup-environment

cd sources
git clone -b imx-5.15.5-vb git@gitlab.com:VoxelBotics/meta-vb-imx8mp.git
cd ..

DISTRO=${DISTRO} MACHINE=imx8mpnavq EULA=yes source ./${SETUP} -b builddir

sed -i 's/^DL_DIR.*$/DL_DIR\ \?=\ \"\/home\/cache\/CACHE\/5.15.5\/downloads\/\"/' conf/local.conf
echo "SSTATE_DIR = \"/home/cache/CACHE/5.15.5/sstate-cache\"" >> conf/local.conf

echo BBLAYERS += \"\${BSPDIR}/sources/meta-vb-imx8mp\" >> conf/bblayers.conf

#devtool modify u-boot-imx
#devtool modify linux-imx

bitbake ${BUILDRECIPE}

finish=`date +%s`; echo "### Build Time = `expr \( $finish - $start \) / 60` minutes"
