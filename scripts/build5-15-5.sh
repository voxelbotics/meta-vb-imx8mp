#!/bin/bash
set -x

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

repo init -u https://source.codeaurora.org/external/imx/imx-manifest  -b imx-linux-honister -m imx-5.15.5-1.0.0.xml

#repo init -u https://source.codeaurora.org/external/imx/imx-manifest -b imx-linux-honister -m imx-5.15.5-1.0.0_desktop.xml
repo sync

# allow build to not prompt for input
sed 's/more\ -d/\#more\ -d/' setup-environment > x && mv -f x setup-environment

cd sources
git clone -b imx-5.15.5-vb git@gitlab.com:VoxelBotics/meta-vb-imx8mp.git
cd ..

DISTRO=fsl-imx-xwayland MACHINE=imx8mpnavq EULA=yes source ./imx-setup-release.sh -b builddir


sed -i 's/^DL_DIR.*$/DL_DIR\ \?=\ \"\/home\/cache\/CACHE\/5.15.5\/downloads\/\"/' conf/local.conf
echo "SSTATE_DIR = \"/home/cache/CACHE/5.15.5/sstate-cache\"" >> conf/local.conf

echo BBLAYERS += \"\${BSPDIR}/sources/meta-vb-imx8mp\" >> conf/bblayers.conf

#devtool modify u-boot-imx
#devtool modify linux-imx

bitbake imx-image-full

finish=`date +%s`; echo "### Build Time = `expr \( $finish - $start \) / 60` minutes"
