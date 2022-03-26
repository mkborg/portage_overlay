# Copyright 2022 Mikhail Krivtsov
# Distributed under the terms of the GNU General Public License v3

EAPI=8

inherit qmake-utils

MY_PV="v${PV}"

DESCRIPTION="Pattern drafting"
HOMEPAGE="https://valentinaproject.bitbucket.io/"
SRC_URI="https://gitlab.com/smart-pattern/${PN}/-/archive/${MY_PV}/${PN}-${MY_PV}.tar.bz2 -> ${P}.tar.bz2"
S="${WORKDIR}/${PN}-${MY_PV}"

KEYWORDS="~amd64"
LICENSE="GPL-3"
SLOT="0"

IUSE=""
LANGS="cs de el en en es fi fr he id it nl pt-BR ro ru uk zh-CN"
for LANG in ${LANGS}; do
	IUSE="${IUSE} l10n_${LANG}"
done

RDEPEND="
	dev-qt/qtxmlpatterns
"

DEPEND="${RDEPEND}
"

src_configure() {
	local locales=""
	local locale

	for LANG in ${LANGS}; do
		if use l10n_${LANG}; then
			case ${LANG} in
			"cs")
				locale="cs_CZ"
				;;
			"de")
				locale="de_DE"
				;;
			"el")
				locale="el_GR"
				;;
			"en")
				locale="en_CA en_IN en_US"
				;;
			"es")
				locale="es_ES"
				;;
			"fi")
				locale="fi_FI"
				;;
			"fr")
				locale="fr_FR"
				;;
			"he")
				locale="he_IL"
				;;
			"id")
				locale="id_ID"
				;;
			"it")
				locale="it_IT"
				;;
			"nl")
				locale="nl_NL"
				;;
			"pt-BR")
				locale="pt_BR"
				;;
			"ro")
				locale="ro_RO"
				;;
			"ru")
				locale="ru_RU"
				;;
			"uk")
				locale="uk_UA"
				;;
			"zh-CN")
				locale="zh_CN"
				;;
			esac

			locales="${locales} ${locale}"
		fi
	done

	local myqmakeargs=(
		"Valentina.pro"
		"-recursive"
		"CONFIG+=no_ccache"
		"CONFIG+=noRunPath"
		"CONFIG+=noTests"
		"LOCALES=${locales}"
	)
	eqmake5 "${myqmakeargs[@]}"
}

src_install() {
	emake install INSTALL_ROOT="${D}"

	dodoc AUTHORS.txt ChangeLog.txt README.txt

	doman dist/debian/${PN}.1
	doman dist/debian/puzzle.1
	doman dist/debian/tape.1

	cp dist/debian/valentina.sharedmimeinfo dist/debian/${PN}.xml || die
	insinto /usr/share/mime/packages
	doins dist/debian/${PN}.xml
}
