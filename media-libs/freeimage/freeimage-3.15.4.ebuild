# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/freeimage/freeimage-3.15.4.ebuild,v 1.4 2013/06/13 12:29:48 xmw Exp $

EAPI=5

inherit eutils multilib toolchain-funcs

MY_PN=FreeImage
MY_PV=${PV//.}
MY_P=${MY_PN}${MY_PV}

DESCRIPTION="Image library supporting many formats"
HOMEPAGE="http://freeimage.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.zip
	mirror://sourceforge/${PN}/${MY_P}.pdf
	mirror://sourceforge/libjpeg-turbo/libjpeg-turbo-1.3.0.tar.gz"

LICENSE="|| ( GPL-2 FIPL-1.0 )"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
IUSE="jpeg jpeg2k mng openexr png raw static-libs tiff"

# The tiff/ilmbase isn't a typo.  The TIFF plugin cheats and
# uses code from it to handle 16bit<->float conversions.
# The depend should be 'jpeg? ( virtual/jpeg:0= )', see bug #479476
RDEPEND="sys-libs/zlib
	jpeg? ( >=media-libs/libjpeg-turbo-1.3.0-r2 )
	jpeg2k? ( media-libs/openjpeg:0= )
	mng? ( media-libs/libmng )
	openexr? ( media-libs/openexr:= )
	png? ( media-libs/libpng:0= )
	raw? ( media-libs/libraw )
	tiff? (
		media-libs/ilmbase:=
		media-libs/tiff:=
	)"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	app-arch/unzip"

S=${WORKDIR}/${MY_PN}

src_prepare() {
	cd Source
	cp "${WORKDIR}"/libjpeg-turbo-1.3.0/{transupp.c,transupp.h,jpegcomp.h,jinclude.h} . || die
#	cp LibJPEG/{transupp.c,transupp.h,jinclude.h} . || die
	cp LibTIFF4/{tiffiop,tif_dir}.h . || die
	rm -rf LibPNG LibMNG LibOpenJPEG ZLib OpenEXR LibRawLite LibTIFF4 LibJPEG || die
	cd ..
	edos2unix Makefile.{gnu,fip,srcs} fipMakefile.srcs */*.h */*/*.cpp
	sed -i \
		-e "s:/./:/:g" \
		-e "s: ./: :g" \
		-e 's: Source: \\\n\tSource:g' \
		-e 's: Wrapper: \\\n\tWrapper:g' \
		-e 's: Examples: \\\n\tExamples:g' \
		-e 's: TestAPI: \\\n\tTestAPI:g' \
		-e 's: -ISource: \\\n\t-ISource:g' \
		-e 's: -IWrapper: \\\n\t-IWrapper:g' \
		Makefile.srcs fipMakefile.srcs || die
	sed -i \
		-e "/LibJPEG/d" \
		-e "/LibPNG/d" \
		-e "/LibTIFF/d" \
		-e "/Source\/ZLib/d" \
		-e "/LibOpenJPEG/d" \
		-e "/OpenEXR/d" \
		-e "/LibRawLite/d" \
		-e "/LibMNG/d" \
		Makefile.srcs fipMakefile.srcs || die
	epatch "${FILESDIR}"/${PN}-3.15.4-{unbundling,raw}.patch
}

foreach_make() {
	local m
	for m in Makefile.{gnu,fip} ; do
		emake -f ${m} \
			USE_EXR=$(usex openexr) \
			USE_JPEG=$(usex jpeg) \
			USE_JPEG2K=$(usex jpeg2k) \
			USE_MNG=$(usex mng) \
			USE_PNG=$(usex png) \
			USE_TIFF=$(usex tiff) \
			USE_RAW=$(usex raw) \
			$(usex static-libs '' STATICLIB=) \
			"$@"
	done
}

src_compile() {
	tc-export AR PKG_CONFIG
	foreach_make \
		CXX="$(tc-getCXX) -fPIC" \
		CC="$(tc-getCC) -fPIC" \
		${MY_PN}
}

src_install() {
	foreach_make install DESTDIR="${ED}" INSTALLDIR="${ED}"/usr/$(get_libdir)
	dodoc Whatsnew.txt "${DISTDIR}"/${MY_P}.pdf
}
