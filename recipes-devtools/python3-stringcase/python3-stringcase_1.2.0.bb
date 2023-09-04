
SUMMARY = "String case converter."
HOMEPAGE = "https://github.com/okunishinishi/python-stringcase"
AUTHOR = "Taka Okunishi <okunishitaka.com@gmail.com>"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=59260a4045da59ac7cb0820ac544b150"

SRC_URI = "https://files.pythonhosted.org/packages/f3/1f/1241aa3d66e8dc1612427b17885f5fcd9c9ee3079fc0d28e9a3aeeb36fa3/stringcase-1.2.0.tar.gz"
SRC_URI[md5sum] = "5cb2a0b28f227f19dc830b66f6e46b52"
SRC_URI[sha256sum] = "48a06980661908efe8d9d34eab2b6c13aefa2163b3ced26972902e3bdfd87008"

S = "${WORKDIR}/stringcase-1.2.0"

RDEPENDS_${PN} = ""

inherit python_setuptools_build_meta
