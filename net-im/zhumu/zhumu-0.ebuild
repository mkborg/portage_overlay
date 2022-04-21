# Copyright 2022 Mikhail Krivtsov
# Distributed under the terms of the GNU General Public License v3

EAPI=8

inherit rpm xdg

DESCRIPTION="Zhumu Video Conferencing ('zoom' clone)"
HOMEPAGE="https://www.zhumu.me/"
#SRC_URI="https://welink.zhumu.com/client/latest/zhumu_amd64.deb -> zhumu_debian-8_amd64.deb"
SRC_URI="https://welink.zhumu.com/client/latest/zhumu-1_amd64.deb -> zhumu_debian-7.7_amd64.deb"

KEYWORDS="~amd64"
LICENSE="Zhumu"
SLOT="0"

IUSE=""

##QA_PREBUILT="*"

S="${WORKDIR}"

src_unpack() {
	default
	unpack "${WORKDIR}"/data.tar.xz

        # provided docs are useless
        rm -r usr/share/doc || die
}

src_install() {
	insinto /
	doins -r opt/
	doins -r usr/

	# Fix permissions
	chmod +x "${ED}"/opt/zhumu/ZhumuLauncher || die
	chmod +x "${ED}"/opt/zhumu/zhumu || die
}
