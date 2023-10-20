
SUMMARY = "Option groups missing in Click"
HOMEPAGE = "https://github.com/click-contrib/click-option-group"
AUTHOR = "Eugene Prilepin <esp.home@gmail.com>"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://LICENSE;md5=f10e5cf198b01ce7c7ed725a55d3b39d"

SRC_URI = "https://files.pythonhosted.org/packages/e7/b8/91054601a2e05fd9060cb1baf56be5b24145817b059e078669e1099529c7/click-option-group-0.5.6.tar.gz"
SRC_URI[md5sum] = "6948f452fa3c42101aad04caf1b5b454"
SRC_URI[sha256sum] = "97d06703873518cc5038509443742b25069a3c7562d1ea72ff08bfadde1ce777"

S = "${WORKDIR}/click-option-group-0.5.6"

RDEPENDS_${PN} = "python3-click"

inherit setuptools3

BBCLASSEXTEND = "native nativesdk"
