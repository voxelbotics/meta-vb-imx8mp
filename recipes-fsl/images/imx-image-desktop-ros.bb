require recipes-fsl/images/imx-image-desktop.bb
require imx-image.inc
require ros2-packages.inc

IMAGE_PREPROCESS_COMMAND:remove = "do_fix_connman_conflict"

IMAGE_INSTALL:append = "opencv \
			opencv-apps \
			opencv-samples \
			python3-opencv \
			tensorflow-lite-vx-delegate \
			packagegroup-imx-ml-desktop \
			"

IMAGE_INSTALL:remove = "chromium-ozone-wayland"

IMAGE_INSTALL += "install-interface-config install-dns-config"

ROOTFS_POSTPROCESS_COMMAND:prepend = " do_ros_repo;"
ROOTFS_POSTPROCESS_COMMAND:remove = " do_update_dns;"
ROOTFS_POSTPROCESS_COMMAND:append = " do_disable_hibernate; do_generate_netplan; \
					do_fix_dns; do_install_home_files;"

APTGET_EXTRA_LIBRARY_PATH="/usr/lib/jvm/java-11-openjdk-arm64/lib/jli"

APTGET_EXTRA_PACKAGES += "\
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

do_generate_netplan() {
	set -x

	echo "network:\n  version: 2\n  renderer: NetworkManager" > ${IMAGE_ROOTFS}/etc/netplan/01-network-manager-all.yaml

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

	echo "<CycloneDDS> \
  	<Domain> \
    	<General> \
      	<NetworkInterfaceAddress>usb0,mlan0</NetworkInterfaceAddress> \
    	</General> \
  	</Domain> \
	</CycloneDDS> \
	" > ${APTGET_CHROOT_DIR}/home/user/CycloneDDSConfig.xml

	echo "source /opt/ros/humble/setup.bash" >> ${APTGET_CHROOT_DIR}/home/user/.bashrc
	echo "source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" >> ${APTGET_CHROOT_DIR}/home/user/.bashrc
	echo "export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp" >> ${APTGET_CHROOT_DIR}/home/user/.bashrc
	echo "export CYCLONEDDS_URI=/home/user/CycloneDDSConfig.xml" >> ${APTGET_CHROOT_DIR}/home/user/.bashrc

	chown user:user ${APTGET_CHROOT_DIR}/home/user/CycloneDDSConfig.xml
	chown user:user ${APTGET_CHROOT_DIR}/home/user/.bashrc

	set +x
}
