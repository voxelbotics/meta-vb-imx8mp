
SUMMARY = "a modern parsing library"
HOMEPAGE = ""
AUTHOR = " <Erez Shinan <erezshin@gmail.com>>"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=fcfbf1e2ecc0f37acbb5871aa0267500"

SRC_URI = "https://files.pythonhosted.org/packages/85/70/4465b0b7dc6ea72cc2c4ea25a2c6ad62cca7918eda030db36a4c11f6f5d9/lark-1.1.7.tar.gz"
SRC_URI[md5sum] = "185c3c1da203557c4b3fbd2f825ccf13"
SRC_URI[sha256sum] = "be7437bf1f37ab08b355f29ff2571d77d777113d0a8c4352b0c513dced6c5a1e"

DEPENDS += "${PYTHON_PN}-wheel-native"

PYPI_PACKAGE = "lark"

#S = "${WORKDIR}/lark-1.1.7"

inherit pypi python_setuptools_build_meta

BBCLASSEXTEND = "native nativesdk"
