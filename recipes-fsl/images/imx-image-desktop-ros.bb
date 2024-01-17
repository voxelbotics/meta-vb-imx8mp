require recipes-fsl/images/imx-image-desktop.bb
require imx-image.inc
require ros2-packages.inc

CUSTOM_FILES_PATH := "${THISDIR}/files"
SRC_URI = " \
	file://btinit.sh \
"

ROOTFS_POSTPROCESS_COMMAND:append = "do_enable_gdm_autologin; do_config_gnome;"
IMAGE_PREPROCESS_COMMAND:remove = "do_fix_connman_conflict"

IMAGE_INSTALL:append = "opencv \
			opencv-apps \
			opencv-samples \
			python3-opencv \
			tensorflow-lite-vx-delegate \
			packagegroup-imx-ml-desktop \
			usb-gadgets-eth2 \
			umtp-responder \
			navq-kmod-mlan \
			gnome-shell-extension-no-overview \
			matter \
			mdns \
			ot-br-posix \
			navq-persistent-storage \
			hdmi-detect \
			u-boot-imx-env \
			libubootenv-bin \
			libubootenv \
			u-boot-env-setup \
			ecpprog \
			"

IMAGE_INSTALL += "install-interface-config install-dns-config"

ROOTFS_POSTPROCESS_COMMAND:prepend = " do_ros_repo; do_vb_repo;"
ROOTFS_POSTPROCESS_COMMAND:remove = " do_update_dns;"
ROOTFS_POSTPROCESS_COMMAND:append = " do_disable_hibernate; \
					do_fix_dns; \
					do_install_home_files; \
					do_fix_bt; \
					do_prepare_docker; "

APTGET_EXTRA_LIBRARY_PATH="/usr/lib/jvm/java-11-openjdk-arm64/lib/jli"

APTGET_EXTRA_PACKAGES += "\
	chrony \
	netplan.io \
	curl \
	gnupg \
	gnupg2 \
	lsb-release \
	input-utils \
	libspnav-dev \
	libbluetooth-dev \
	libcwiid-dev \
	jstest-gtk \
	bash-completion \
	build-essential \
	cmake \
	git \
	ccache \
	can-utils \
	pkg-config \
	python3-colcon-common-extensions \
	python3-flake8 \
	python3-pip \
	python3-dev \
	python3-pytest-cov \
	python3-rosdep \
	python3-setuptools \
	python3-testresources \
	python3-vcstools \
	python3-argcomplete \
	python3-empy \
	python3-jinja2 \
	python3-cerberus \
	python3-coverage \
	python3-matplotlib \
	python3-numpy \
	python3-packaging \
	python3-pkgconfig \
	python3-opencv \
	python3-wheel \
	python3-requests \
	python3-serial \
	python3-six \
	python3-toml \
	python3-psutil \
	python3-pysolar \
	python3-flake8-blind-except \
	python3-flake8-builtins \
	python3-flake8-class-newline \
	python3-flake8-comprehensions \
	python3-flake8-deprecated \
	python3-flake8-docstrings \
	python3-flake8-import-order \
	python3-flake8-quotes \
	python3-pytest-repeat \
	python3-pytest-rerunfailures \
	python3-pytest \
	python3-can \
	g++ \
	gcc \
	gdb \
	ninja-build \
	make \
	bzip2 \
	zip \
	rsync \
	shellcheck \
	tzdata \
	unzip \
	valgrind \
	xsltproc \
	binutils \
	bc \
	libyaml-cpp-dev \
	autoconf \
	automake \
	bison \
	ca-certificates \
	openssh-client \
	cppcheck \
	dirmngr \
	doxygen \
	file \
	gosu \
	lcov \
	libfreetype6-dev \
	libgtest-dev \
	libpng-dev \
	libssl-dev \
	libopencv-dev \
	flex \
	genromfs \
	gperf \
	libncurses-dev \
	libtool \
	uncrustify \
	vim-common \
	libxml2-utils \
	mesa-utils \
	libeigen3-dev \
	protobuf-compiler \
	libimage-exiftool-perl \
	v4l-utils \
	gstreamer1.0-nice \
	gstreamer1.0-opencv \
	iw   \
	usbutils \
	qtwayland5 \
	docker.io \
	docker-compose \
	radvd \
	${@bb.utils.contains('PACKAGE_CLASSES', 'package_rpm', 'rpm', '', d)} \
	picocom	\
"

APTGET_EXTRA_PACKAGES_LAST += " \
	ros-humble-desktop \
	ros-humble-cv-bridge \
	ros-humble-image-tools \
	ros-humble-image-transport \
	ros-humble-image-transport-plugins \
	ros-humble-camera-calibration-parsers \
	ros-humble-camera-info-manager \
	ros-humble-launch-testing-ament-cmake \
	ros-humble-vision-opencv \
	ros-humble-image-pipeline \
	${ROS_HUMBLE_MSGS} \
	${ROS_HUMBLE_RMWS} \
	ros-humble-pmd-camera-ros \
	libroyale-royaleviewer \
"

# Couldn't get v4l2loopback-utils because of dkms failure. Try later maybe?

APTGET_EXTRA_PACKAGES:remove = "\
	connman \
"

do_disable_hibernate() {
	set -x

	ln -s /dev/null ${IMAGE_ROOTFS}/etc/systemd/system/sleep.target
	ln -s /dev/null ${IMAGE_ROOTFS}/etc/systemd/system/suspend.target
	ln -s /dev/null ${IMAGE_ROOTFS}/etc/systemd/system/hibernate.target
	ln -s /dev/null ${IMAGE_ROOTFS}/etc/systemd/system/hybrid-sleep.target
	sed -i 's/#Allow/Allow/g' ${IMAGE_ROOTFS}/etc/systemd/sleep.conf
	sed -i 's/=yes/=no/g' ${IMAGE_ROOTFS}/etc/systemd/sleep.conf

	set +x
}

fakeroot do_ros_repo() {
	set -x

	wget https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -O ${APTGET_CHROOT_DIR}/usr/share/keyrings/ros-archive-keyring.gpg
	echo "deb [arch=arm64 signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu jammy main" > ${APTGET_CHROOT_DIR}/etc/apt/sources.list.d/ros2.list

	set +x
}

fakeroot do_vb_repo() {
	set -x

	echo "deb [trusted=yes] https://vb-files.fra1.digitaloceanspaces.com/debian/ jammy voxelbotics" > ${APTGET_CHROOT_DIR}/etc/apt/sources.list.d/voxelbotics.list

	set +x
}

fakeroot do_generate_netplan() {
	set -x

	echo -e "network:\n  version: 2\n  renderer: NetworkManager" > ${IMAGE_ROOTFS}/etc/netplan/01-network-manager-all.yaml

	set +x
}

fakeroot do_fix_dns() {
	set -x

	rm "${APTGET_CHROOT_DIR}/etc/resolv.conf"
	echo "nameserver 8.8.8.8" > "${APTGET_CHROOT_DIR}/etc/resolv.conf"

	set +x
}

fakeroot do_install_home_files() {
	set -x

	wget -q -P ${APTGET_CHROOT_DIR}/home/user/ https://raw.githubusercontent.com/rudislabs/NavQPlus-Resources/lf-5.15.32_2.0.0/configs/CycloneDDSConfig.xml

	echo "source /opt/ros/humble/setup.bash" >> ${APTGET_CHROOT_DIR}/home/user/.bashrc
	echo "source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" >> ${APTGET_CHROOT_DIR}/home/user/.bashrc
	echo "export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp" >> ${APTGET_CHROOT_DIR}/home/user/.bashrc
	echo "export CYCLONEDDS_URI=/home/\$USER/CycloneDDSConfig.xml" >> ${APTGET_CHROOT_DIR}/home/user/.bashrc

	chown user:user ${APTGET_CHROOT_DIR}/home/user/CycloneDDSConfig.xml
	chown user:user ${APTGET_CHROOT_DIR}/home/user/.bashrc

	set +x
}

fakeroot do_aptget_user_update() {
	wget -q -P ${APTGET_CHROOT_DIR}/ https://github.com/rudislabs/NavQPlus-Resources/raw/lf-5.15.32_2.0.0/python/tflite_runtime-2.12.0-cp310-cp310-linux_aarch64.whl
	chroot ${APTGET_CHROOT_DIR} /usr/bin/pip3 install tflite_runtime-2.12.0-cp310-cp310-linux_aarch64.whl
	rm -f ${APTGET_CHROOT_DIR}/tflite_runtime-2.12.0-cp310-cp310-linux_aarch64.whl
	chroot ${APTGET_CHROOT_DIR} /usr/sbin/adduser user plugdev
	chroot ${APTGET_CHROOT_DIR} /usr/sbin/adduser user input

	# configure synchronization with Create3
	cat > ${APTGET_CHROOT_DIR}/etc/chrony/conf.d/create3.conf <<-EOF
		# Make it slightly to the past so host/rviz wouldn't complain
		pool ntp.ubuntu.com        iburst maxsources 4 offset -0.3
		pool 0.ubuntu.pool.ntp.org iburst maxsources 1 offset -0.3
		pool 1.ubuntu.pool.ntp.org iburst maxsources 1 offset -0.3
		pool 2.ubuntu.pool.ntp.org iburst maxsources 2 offset -0.3
		# Enable serving time to ntp clients on 192.168.186.0 subnet.
		allow 192.168.186.0/24
		# Serve time even if not synchronized to a time source
		local stratum 10
		EOF
}

do_enable_gdm_autologin () {
    # Enable gdm auto-login
    sed -i "s/#  AutomaticLoginEnable = true/AutomaticLoginEnable = true/" ${IMAGE_ROOTFS}/etc/gdm3/custom.conf
    sed -i "s/#  AutomaticLogin = user1/AutomaticLogin = user/" ${IMAGE_ROOTFS}/etc/gdm3/custom.conf
}

DEPENDS:append = " dconf-native"

fakeroot do_config_gnome () {
    set -x

    install -d ${IMAGE_ROOTFS}${sysconfdir}/dconf/profile
    echo "user-db:user" > ${IMAGE_ROOTFS}${sysconfdir}/dconf/profile/user
    echo "system-db:local" >> ${IMAGE_ROOTFS}${sysconfdir}/dconf/profile/user

    install -d ${IMAGE_ROOTFS}${sysconfdir}/dconf/db/local.d
    echo "[org/gnome/desktop/screensaver]" > ${IMAGE_ROOTFS}${sysconfdir}/dconf/db/local.d/00-gnome-config
    echo -e "lock-enabled=false\n" >> ${IMAGE_ROOTFS}${sysconfdir}/dconf/db/local.d/00-gnome-config
    echo "[org/gnome/settings-daemon/plugins/power]" >> ${IMAGE_ROOTFS}${sysconfdir}/dconf/db/local.d/00-gnome-config
    echo -e "sleep-inactive-ac-type='nothing'\n" >> ${IMAGE_ROOTFS}${sysconfdir}/dconf/db/local.d/00-gnome-config
    echo "[org/gnome/desktop/session]" >> ${IMAGE_ROOTFS}${sysconfdir}/dconf/db/local.d/00-gnome-config
    echo -e "idle-delay=uint32 0\n" >> ${IMAGE_ROOTFS}${sysconfdir}/dconf/db/local.d/00-gnome-config
    echo "[org/gnome/shell]" >> ${IMAGE_ROOTFS}${sysconfdir}/dconf/db/local.d/00-gnome-config
    echo "enabled-extensions=['no-overview@fthx']" >> ${IMAGE_ROOTFS}${sysconfdir}/dconf/db/local.d/00-gnome-config

    dconf update ${IMAGE_ROOTFS}${sysconfdir}/dconf/db

    set +x
}

fakeroot do_prepare_docker () {
    sed -i 's/\/systemd-networkd-wait-online/\/systemd-networkd-wait-online --any/' ${IMAGE_ROOTFS}/lib/systemd/system/systemd-networkd-wait-online.service

    ln -sf /usr/sbin/iptables-legacy ${IMAGE_ROOTFS}/etc/alternatives/iptables
    ln -sf /usr/sbin/iptables-legacy-save ${IMAGE_ROOTFS}/etc/alternatives/iptables-save
    ln -sf /usr/sbin/iptables-legacy-restore ${IMAGE_ROOTFS}/etc/alternatives/iptables-restore

    ln -sf /usr/sbin/ip6tables-legacy ${IMAGE_ROOTFS}/etc/alternatives/ip6tables
    ln -sf /usr/sbin/ip6tables-legacy-save ${IMAGE_ROOTFS}/etc/alternatives/ip6tables-save
    ln -sf /usr/sbin/ip6tables-legacy-restore ${IMAGE_ROOTFS}/etc/alternatives/ip6tables-restore
}

do_fix_bt () {
	install -m 0755 ${CUSTOM_FILES_PATH}/btinit.sh ${IMAGE_ROOTFS}/usr/bin/

	sed -i 's/bluetoothd/bluetoothd -C -E\nExecStartPre=\/usr\/bin\/btinit.sh/' ${IMAGE_ROOTFS}/lib/systemd/system/bluetooth.service
	sed -i 's/CAP_NET_BIND_SERVICE/CAP_NET_BIND_SERVICE CAP_NET_RAW/' ${IMAGE_ROOTFS}/lib/systemd/system/bluetooth.service
}
