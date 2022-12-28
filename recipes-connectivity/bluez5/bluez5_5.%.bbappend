FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# Do not start the service during system boot up
INITSCRIPT_PARAMS:${PN} = "stop 20 0 1 6 ."

# Add patch for module bcm43xx
# Add patches for QCA modules with Qca6174 and Qca9377-3 chips
SRC_URI += " \
            file://0001-add-hciattach-to-service.patch \
"

