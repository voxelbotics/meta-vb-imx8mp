# Copyrigh (C) 2022 Voxelbotics
DESCRIPTION = "NAVQ+ rootfs image"
SECTION = ""

LICENSE = "MIT"

IMAGE_FSTYPES = "tar.bz2"

include recipes-core/images/core-image-minimal.bb

IMAGE_FEATURES += "			\
    package-management			\
"

IMAGE_INSTALL:append = "		\
    navq-files				\
    umtp-responder			\
    openssh				\
    opkg				\
    swupdate				\
    e2fsprogs				\
    dosfstools				\
    libgcc				\
    u-boot-imx-env			\
    libubootenv-bin			\
    libubootenv				\
"
