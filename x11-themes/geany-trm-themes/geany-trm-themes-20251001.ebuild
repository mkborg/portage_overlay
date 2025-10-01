
EAPI=8

DESCRIPTION="A collection of colour schemes for Geany"
HOMEPAGE="http://www.totallyrandomman.x10host.com/programming/geany/color-schemes.htm"
SRC_URI="http://www.totallyrandomman.x10host.com/programming/geany/trm_geany_schemes.tar.gz"

SLOT="0"
KEYWORDS="amd64 x86"

RDEPEND="dev-util/geany"

src_unpack() {
  echo 'src_unpack'

  echo ". A='${A}'"
  echo ". D='${D}'"
  echo ". P='${P}'"
  echo ". S='${S}'"

  unpack ${A}

  mkdir -pv "${S}/colorschemes"
  mv *.conf "${S}/colorschemes/"
}

src_install() {
	default

	insinto /usr/share/geany
	doins -r colorschemes
}
