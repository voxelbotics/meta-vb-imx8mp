#!/bin/bash
set -x

BUILD_DESKTOP="yes"
SETTAG="HEAD"
BRANCH=imx-5.15.32-vb

S3BUCKET="vb-files"
S3BASE="fra1.digitalopenspaces.com"

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
    MANIFEST="imx-5.15.32-2.0.0_desktop.xml"
    DISTRO="imx-desktop-xwayland"
    SETUP="imx-setup-desktop.sh"
    IMGNAME="imx-image-desktop"
    BUILDRECIPES="imx-image-desktop navq-install-desktop"
    BUILDDIR="build-desktop"
    BBMASK=""
else
    MANIFEST="imx-5.15.32-1.0.0.xml"
    DISTRO="fsl-imx-xwayland"
    IMGNAME="imx-image-full"
    BUILDRECIPES="imx-image-full navq-install"
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


BUILD=`date +%Y%m%d.%H%M`; start=`date +%s`
#git config --global user.email "kent@emcraft.com"
#git config --global user.name "Kent Meyer"


mkdir -p $BUILDDIR
cd $BUILDDIR

repo init -u https://source.codeaurora.org/external/imx/imx-manifest -b imx-linux-kirkstone -m ${MANIFEST} || exit $?
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


DISTRO=${DISTRO} MACHINE=imx8mpnavq EULA=yes BUILD_DIR=builddir source ./${SETUP} || exit $?

sed -i 's/^DL_DIR.*$/DL_DIR\ \?=\ \"\/home\/cache\/CACHE\/5.15.32\/downloads\/\"/' conf/local.conf || exit $?
echo "SSTATE_DIR = \"/home/cache/CACHE/5.15.32/sstate-cache\"" >> conf/local.conf || exit $?
echo "IMAGE_INSTALL:append = \" navq-files \"" >> conf/local.conf || exit $?
echo "BBMASK += \"$BBMASK\"" >> conf/local.conf || exit $?
echo "BB_DEFAULT_UMASK = \"0002\"" >> conf/local.conf || exit $?
sed -i -e "s/BB_DEFAULT_UMASK =/BB_DEFAULT_UMASK ?=/" ../sources/poky/meta/conf/bitbake.conf

echo BBLAYERS += \"\${BSPDIR}/sources/meta-vb-imx8mp\" >> conf/bblayers.conf || exit $?

echo $RELEASE_VER > ${BUILDDIR}/../sources/meta-vb-imx8mp/recipes-fsl/images/files/vb-release || exit $?
echo "LOCALVERSION = \"-$RELEASE_VER\"" >> ${BUILDDIR}/../sources/meta-vb-imx8mp/recipes-bsp/u-boot/u-boot-imx_2022.04.bbappend || exit $?
echo "LOCALVERSION = \"-$RELEASE_VER\"" >> ${BUILDDIR}/../sources/meta-vb-imx8mp/recipes-kernel/linux/linux-imx_5.15.bbappend || exit $?

if [ "$SETTAG" != "HEAD" ]; then
        pushd ../tmp/u-boot-imx;hash=$(git show-ref -s $SETTAG);popd
        echo "# Use hash for tag $SETTAG" >> conf/site.conf
        echo "SRCREV:pn-u-boot-imx = \"$hash\"" >> conf/site.conf
        echo "# Use hash for tag $SETTAG" >> conf/site.conf
        pushd ../tmp/linux-imx;hash=$(git show-ref -s $SETTAG);popd
        echo "SRCREV:pn-linux-imx = \"$hash\"" >> conf/site.conf
fi

#devtool modify u-boot-imx
#devtool modify linux-imx

bitbake ${BUILDRECIPES} uuu-native || exit $?

echo "$yocto_info" >> $BUILDDIR/tmp/deploy/images/imx8mpnavq/$IMGNAME-imx8mpnavq.manifest || exit $?

files=(
	Image
	imx8mp-navq.dtb
	imx-boot-imx8mpnavq-sd.bin-flash_evk
	imx-image-desktop-imx8mpnavq.tar.bz2
	imx-image-desktop-imx8mpnavq.wic.bz2
	imx-image-full-imx8mpnavq.tar.bz2
	imx-image-full-imx8mpnavq.wic.bz2
	navq-dbg.uuu
	navq-install-desktop.uuu
	navq-install.uuu
	navq-install-initrd.uImage
	partitions.sfdisk
)

# copy artifacts
if [ -d "$DST" ]; then
	mkdir -p $DST/$RELEASE_VER
	for i in ${files[*]}; do
		file=$BUILDDIR/tmp/deploy/images/imx8mpnavq/$i
		if [ -f $file ]; then
			cp $file $DST/$RELEASE_VER/
		fi
	done
	# upload to S3 bucket
	cd $DST/$RELEASE_VER/
	zip -1 -n bz2 /tmp/${RELEASE_VER}-navqp.zip *
	# if version starts with 0. or HEAD, use the "nightly/" folder on S3,
	# otherwise, use "release/"
	echo $RELEASE_VER | grep -o "^0.\|^HEAD"
	if [ $? -eq 0 ]; then
	    path="nightly"
	else
	    path="release"
	fi
	cd -
	s3cmd put /tmp/${RELEASE_VER}-navqp.zip s3://${S3BUCKET}/${path}/
	if [ $? -eq 0 ]; then
	    echo "Uploaded to https://${S3BUCKET}.${S3BASE}/${path}/${RELEASE_VER}-navqp.zip"
	    s3cmd setacl --acl-public s3://${S3BUCKET}/${path}/${RELEASE_VER}-navqp.zip
	else
	    echo "Error uploading /tmp/${RELEASE_VER}-navqp.zip to s3://${S3BUCKET}/${path}/"
	fi
	rm /tmp/${RELEASE_VER}-navqp.zip
fi

finish=`date +%s`; echo "### Build Time = `expr \( $finish - $start \) / 60` minutes"
