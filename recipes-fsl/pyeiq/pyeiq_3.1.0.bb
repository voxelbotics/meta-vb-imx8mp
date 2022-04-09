DESCRIPTION = "A Python Demo Framework for eIQ on i.MX Processors"
HOMEPAGE = "https://pypi.org/project/pyeiq/"
SECTION = "devel/python"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://LICENSE.md;md5=f46dd1854380bbca2d764d4db923c46c"

SRC_URI[sha256sum] = "9b101861016840d1183f25728feba2448c1c677fef91c4b8367fcc29f92f29b3"

inherit pypi setuptools3

RDEPENDS:${PN} += " \
	${PYTHON_PN}-profile \
"
