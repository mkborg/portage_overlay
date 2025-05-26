# Copyright 2025 Mikhail Krivtsov
# Distributed under the terms of the GNU General Public License v3

EAPI=8

inherit autotools

DESCRIPTION="TCP/IP emulator which turns an ordinary shell account into a (C)SLIP/PPP account."
HOMEPAGE="http://packages.qa.debian.org/s/slirp.html"
SRC_URI="mirror://debian/pool/main/s/${PN}/${PN}_1.0.17.orig.tar.gz
	mirror://debian/pool/main/s/${PN}/${PN}_1.0.17-11.debian.tar.xz"

LICENSE="BSD-like"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE="+ppp"

DEPEND=""
RDEPEND=""

PATCHES=(
	"${WORKDIR}/debian/patches/001-update-man-fix-hyphens-as-minus.patch"
	"${WORKDIR}/debian/patches/002-fix-arguements.patch"
	"${WORKDIR}/debian/patches/003-socklen_t.patch"
	"${WORKDIR}/debian/patches/004-compilation-warnings.patch"
	"${WORKDIR}/debian/patches/005-use-snprintf.patch"
	"${WORKDIR}/debian/patches/006-changelog-1.0.17.patch"
	"${WORKDIR}/debian/patches/007-debian-changes.patch"
	"${WORKDIR}/debian/patches/008-slirp-amd64-log-crash.patch"
#	"${WORKDIR}/debian/patches/009-i-hate-perl.patch"
	"${WORKDIR}/debian/patches/010-fullbolt-fix.patch"
	"${WORKDIR}/debian/patches/011-sizeof_ipv4.patch"
	"${WORKDIR}/debian/patches/012_ipq64.patch"
	"${WORKDIR}/debian/patches/013_hurd.patch"
	"${WORKDIR}/debian/patches/014_CVE-2020-7039.patch"
	"${WORKDIR}/debian/patches/015_949003_explicit_extern_declaration.patch"
	"${WORKDIR}/debian/patches/016_c11b4078042_fix_64_bit_issue_in_slirp.patch"
	"${WORKDIR}/debian/patches/017_CVE-2020-8608.patch"

	"${FILESDIR}/${P}-perl.patch"
	"${FILESDIR}/${P}-destdir.patch"
	"${FILESDIR}/${P}-fullbolt.patch"

	"${FILESDIR}/${P}-Makefile.in_configure.in.patch"
	"${FILESDIR}/${P}-if.c-inline.patch"
	"${FILESDIR}/${P}-misc.c-inline.patch"
)

src_prepare() {
    default

    # We do not need extra src subdir
    mv src/* ./ && rmdir src

    eautoreconf
}

src_configure() {
    econf \
	$(use_enable ppp)
}

src_install() {
    emake DESTDIR="${D}" install || die "emake install failed"

    dodoc ChangeLog CONTRIB README README.NEXT TODO docs/*
    # newdoc ${WORKDIR}/README README-1.0.17
}
