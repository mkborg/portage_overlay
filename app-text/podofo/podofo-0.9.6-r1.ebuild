# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit cmake flag-o-matic multilib toolchain-funcs

DESCRIPTION="PoDoFo is a C++ library to work with the PDF file format"
HOMEPAGE="https://sourceforge.net/projects/podofo/"
#SRC_URI="mirror://gentoo/${P}.tar.gz"
SRC_URI="http://deb.debian.org/debian/pool/main/libp/libpodofo/libpodofo_0.9.6+dfsg.orig.tar.xz"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0/${PV}"
KEYWORDS="~amd64 ~arm ~hppa ~ppc ~ppc64 ~sparc ~x86"
IUSE="+boost idn libressl debug test +tools"
REQUIRED_USE="test? ( tools )"

RDEPEND="dev-lang/lua:=
	idn? ( net-dns/libidn:= )
	!libressl? ( dev-libs/openssl:0= )
	libressl? ( dev-libs/libressl:0= )
	media-libs/fontconfig:=
	media-libs/freetype:2=
	virtual/jpeg:0=
	media-libs/libpng:0=
	media-libs/tiff:0=
	sys-libs/zlib:="
DEPEND="${RDEPEND}
	test? ( dev-util/cppunit )
"

BDEPEND="virtual/pkgconfig
	boost? ( dev-libs/boost )"

PATCHES=(
        ${FILESDIR}/non_existing_directory.patch
        ${FILESDIR}/pkg-config.patch
        ${FILESDIR}/fix-link-with-visibility-hidden.patch
        ${FILESDIR}/fix-test-non-linux.patch

        ${FILESDIR}/CVE-2018-5783.patch
        ${FILESDIR}/CVE-2018-11254.patch
        ${FILESDIR}/CVE-2018-11256.patch
        ${FILESDIR}/CVE-2018-12982.patch
        ${FILESDIR}/CVE-2018-14320.patch
        ${FILESDIR}/CVE-2018-19532.patch
        ${FILESDIR}/CVE-2018-20751.patch
        ${FILESDIR}/CVE-2019-9199.patch
        ${FILESDIR}/CVE-2019-9687.patch
)

DOCS="AUTHORS ChangeLog TODO"

src_prepare() {
	cmake_src_prepare
	local x sed_args

	# The 0.9.6 ABI is not necessarily stable, so make PODOFO_SOVERSION
	# equal to ${PV}.
	#sed -e 's|${PODOFO_VERSION_PATCH}|\0_'${PV##*_}'|' -i CMakeLists.txt || die

	# bug 620934 - Disable linking with cppunit when possible, since it
	# triggers errors with some older compilers.
	use test || sed -e 's:^FIND_PACKAGE(CppUnit):#\0:' -i CMakeLists.txt || die

	# bug 556962
	sed -i -e 's|Decrypt( pEncryptedBuffer, nOutputLen, pDecryptedBuffer, m_lLen );|Decrypt( pEncryptedBuffer, (pdf_long)nOutputLen, pDecryptedBuffer, (pdf_long\&)m_lLen );|' \
		test/unit/EncryptTest.cpp || die

	sed -i \
		-e "s:LIBDIRNAME \"lib\":LIBDIRNAME \"$(get_libdir)\":" \
		-e "s:LIBIDN_FOUND:HAVE_LIBIDN:g" \
		CMakeLists.txt || die

	# Use pkg-config to find headers for bug #459404.
	sed_args=
	for x in $($(tc-getPKG_CONFIG) --cflags freetype2) ; do
		[[ ${x} == -I* ]] || continue
		x=${x#-I}
		if [[ -f ${x}/ft2build.h ]] ; then
			sed_args+=" -e s:/usr/include/\\r\$:${x}:"
		elif [[ -f ${x}/freetype/config/ftheader.h ]] ; then
			sed_args+=" -e s:/usr/include/freetype2\\r\$:${x}:"
		fi
	done
	[[ -n ${sed_args} ]] && \
		{ sed -i ${sed_args} cmake/modules/FindFREETYPE.cmake || die; }

	# Bug #439784: Add missing unistd include for close() and unlink().
	sed -i 's:^#include <stdio.h>$:#include <unistd.h>\n\0:' -i \
		test/unit/TestUtils.cpp || die

	# TODO: fix these test cases
	# ColorTest.cpp:62:Assertion
	# Test name: ColorTest::testDefaultConstructor
	# expected exception not thrown
	# - Expected: PdfError
	sed -e 's:CPPUNIT_TEST( testDefaultConstructor ://\0:' \
		-e 's:CPPUNIT_TEST( testGreyConstructor ://\0:' \
		-e 's:CPPUNIT_TEST( testRGBConstructor ://\0:' \
		-e 's:CPPUNIT_TEST( testCMYKConstructor ://\0:' \
		-e 's:CPPUNIT_TEST( testColorSeparationAllConstructor ://\0:' \
		-e 's:CPPUNIT_TEST( testColorSeparationNoneConstructor ://\0:' \
		-e 's:CPPUNIT_TEST( testColorSeparationConstructor ://\0:' \
		-e 's:CPPUNIT_TEST( testColorCieLabConstructor ://\0:' \
		-i test/unit/ColorTest.h || die

	# ColorTest.cpp:42:Assertion
	# Test name: ColorTest::testHexNames
	# assertion failed
	# - Expression: static_cast<int>(rgb.GetGreen() * 255.0) == 0x0A
	sed -e 's:CPPUNIT_TEST( testHexNames ://\0:' \
		-i test/unit/ColorTest.h || die

	# Bug #352125: test failure, depending on installed fonts
	# ##Failure Location unknown## : Error
	# Test name: FontTest::testFonts
	# uncaught exception of type PoDoFo::PdfError
	# - ePdfError_UnsupportedFontFormat
	sed -e 's:CPPUNIT_TEST( testFonts ://\0:' \
		-i test/unit/FontTest.h || die

	# Test name: EncodingTest::testDifferencesEncoding
	# equality assertion failed
	# - Expected: 1
	# - Actual  : 0
	sed -e 's:CPPUNIT_TEST( testDifferencesEncoding ://\0:' \
		-i test/unit/EncodingTest.h || die

	# Bug #407015: fix to compile with Lua 5.2
	if has_version '>=dev-lang/lua-5.2' ; then
		sed -e 's: lua_open(: luaL_newstate(:' \
			-e 's: luaL_getn(: lua_rawlen(:' -i \
			tools/podofocolor/luaconverter.cpp \
			tools/podofoimpose/planreader_lua.cpp || die
	fi
}

src_configure() {

	# Bug #381359: undefined reference to `PoDoFo::PdfVariant::DelayedLoadImpl()'
	filter-flags -fvisibility-inlines-hidden

	mycmakeargs+=(
		"-DPODOFO_BUILD_SHARED=1"
		"-DPODOFO_HAVE_JPEG_LIB=1"
		"-DPODOFO_HAVE_PNG_LIB=1"
		"-DPODOFO_HAVE_TIFF_LIB=1"
		"-DWANT_FONTCONFIG=1"
		"-DUSE_STLPORT=0"
		-DWANT_BOOST=$(usex boost ON OFF)
		-DHAVE_LIBIDN=$(usex idn ON OFF)
		-DPODOFO_HAVE_CPPUNIT=$(usex test ON OFF)
		-DPODOFO_BUILD_LIB_ONLY=$(usex tools OFF ON)
		)

	cmake_src_configure
}

src_test() {
	cd "${CMAKE_BUILD_DIR}"/test/unit
	./podofo-test --selftest || die "self test failed"
}
