IMAGE_INSTALL:remove += " \
		     chromium-ozone-wayland \
		     "

IMAGE_INSTALL:append += " \
                         opencv \     
                         opencv-apps \
                         opencv-samples \
                         python3-opencv \
                         tensorflow-lite-vx-delegate \
                         packagegroup-imx-ml-desktop \
                         umtp-responder \
                        "

APT_GET_EXTRA_PACKAGES += " \
		       v4l-utils \
		       "
