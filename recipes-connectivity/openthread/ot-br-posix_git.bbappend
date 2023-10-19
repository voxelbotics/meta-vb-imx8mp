# SPDX-FileCopyrightText: Huawei Inc.
#
# SPDX-License-Identifier: Apache-2.0
SUMMARY = "OpenThread Border Router"
SECTION = "net"
LICENSE = "BSD-3-Clause & MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=87109e44b2fda96a8991f27684a7349c \
                    file://third_party/Simple-web-server/repo/LICENSE;md5=091ac9fd29d87ad1ae5bf765d95278b0 \
                    file://third_party/cJSON/repo/LICENSE;md5=218947f77e8cb8e2fa02918dc41c50d0 \
                    file://third_party/http-parser/repo/LICENSE-MIT;md5=9bfa835d048c194ab30487af8d7b3778 \
                    file://third_party/openthread/repo/LICENSE;md5=543b6fe90ec5901a683320a36390c65f \
                    "
DEPENDS = "autoconf-archive dbus mdns readline jsoncpp boost libnetfilter-queue protobuf protobuf-c protobuf-native "
SRCREV = "4e55cc0ff017f9bb94b2531124ca37332c684b56"
PV = "2023-10-17+git${SRCPV}"

SRC_URI = "gitsm://github.com/openthread/ot-br-posix.git;protocol=https;branch=main \
           "

S = "${WORKDIR}/git"
SYSTEMD_SERVICE:${PN} = "otbr-agent.service"
SYSTEMD_AUTO_ENABLE:${PN} = "disable"

inherit pkgconfig cmake systemd
CXXFLAGS:append:libc-musl:toolchain-clang = " -Wno-error=sign-compare -Wno-error=unused-but-set-variable"

EXTRA_OECMAKE = "-DBUILD_TESTING=OFF \
                 -DOTBR_DBUS=ON \
                 -DOTBR_REST=ON \
                 -DOTBR_WEB=OFF \
                 -DCMAKE_LIBRARY_PATH=${libdir} \
                 -DOTBR_MDNS=mDNSResponder \
                 -DOTBR_BACKBONE_ROUTER=ON \
                 -DOTBR_BORDER_ROUTING=ON \
                 -DOT_BACKBONE_ROUTER_MULTICAST_ROUTING=ON \
                 -DOTBR_SRP_ADVERTISING_PROXY=ON \
                 -DOTBR_BORDER_AGENT=ON \
                 -DOT_SPINEL_RESET_CONNECTION=ON \
                 -DOT_TREL=ON \
                 -DOT_MLR=ON \
                 -DOT_SRP_SERVER=ON \
                 -DOT_ECDSA=ON \
                 -DOT_SERVICE=ON \
                 -DOTBR_DUA_ROUTING=ON \
                 -DOT_DUA=ON \
                 -DOT_BORDER_ROUTING_NAT64=ON \
                 -DOTBR_DNSSD_DISCOVERY_PROXY=ON \
                 -DOTBR_INFRA_IF_NAME=mlan0 \
                 -DOTBR_NO_AUTO_ATTACH=1 \
                 -DOT_REFERENCE_DEVICE=ON \
                 -DOT_DHCP6_CLIENT=ON \
                 -DOT_DHCP6_SERVER=ON \
                 -DOT_BORDER_ROUTER=ON \
                 -DOT_BORDER_AGENT=ON \
                 -DOT_COMMISSIONER=ON \
                 -DOT_COAP=ON \
                 -DOT_COAP_BLOCK=OFF \
                 -DOT_COAP_OBSERVE=ON \
                 -DOT_COAPS=ON \
                 -DOT_DNS_CLIENT=ON \                 
                 -DOT_DUA=ON \
                 -DOT_ECDSA=ON \
                 -DOT_FIREWALL=ON \
                 -DOT_FULL_LOGS=ON \
                 -DOT_JOINER=ON \
                 -DOT_LOG_LEVEL_DYNAMIC=OFF \
                 -DOT_LOG_LEVEL=DEBG \
                 -DOT_RCP_RESTORATION_MAX_COUNT=5 \
                 -DOT_REFERENCE_DEVICE=ON \
                 -DOT_SRP_CLIENT=ON \
                 -DOT_SRP_SERVER=ON \
                 -DOT_THREAD_VERSION=1.3 \
                 "

do_install:append() {
    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/build/tools/pskc ${D}/usr/bin
}

RDEPENDS:${PN} = "iproute2 ipset mdns"

RCONFLICTS:${PN} = "ot-daemon"

FILES:${PN} += "${systemd_unitdir}/*"
FILES:${PN} += "${datadir}/*"
FILES:${PN} += "${bindir}/*"

