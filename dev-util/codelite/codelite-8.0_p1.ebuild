EAPI="5"

inherit git-r3 cmake-utils

EGIT_REPO_URI="https://github.com/eranif/${PN}.git"
EGIT_COMMIT="8.0-1"

LICENSE="GPL-2"
SLOT="0"
IUSE=""

KEYWORDS="~amd64"

RDEPEND="
>=x11-libs/wxGTK-3.0.0.0
net-libs/libssh
dev-libs/libedit
"
