IMAGE_INSTALL_remove += " \
		     chromium-ozone-wayland \
		     "

IMAGE_INSTALL_append += " \
                         opencv \     
                         opencv-apps \
                         opencv-samples \
                         python3-opencv \
                         tensorflow-lite-vx-delegate \
                         packagegroup-imx-ml-desktop \
                        "

APT_GET_EXTRA_PACKAGES += " \
		       v4l-utils \
		       "