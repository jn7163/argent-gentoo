# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-themes/oxygen-gtk/oxygen-gtk-1.1.1.ebuild,v 1.6 2012/12/10 16:13:41 ago Exp $

EAPI=4

MY_PN=${PN}3
MY_P=${MY_PN}-${PV}

inherit cmake-utils

DESCRIPTION="Official GTK+:3 port of KDE's Oxygen widget style"
HOMEPAGE="https://projects.kde.org/projects/playground/artwork/oxygen-gtk"
SRC_URI="mirror://kde/stable/${MY_PN}/${PV}/src/${MY_P}.tar.bz2"

LICENSE="LGPL-2.1"
KEYWORDS="amd64 ~ppc x86"
SLOT="3"
IUSE="debug doc"

RDEPEND="
	!x11-themes/oxygen-gtk:0
	dev-libs/dbus-glib
	dev-libs/glib
	x11-libs/cairo
	x11-libs/gtk+:3
	x11-libs/libX11
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	doc? ( app-doc/doxygen )
"

DOCS=(AUTHORS README TODO)

S="${WORKDIR}/${MY_P}"

src_install() {
	if use doc; then
		{ cd "${S}" && doxygen Doxyfile; } || die "Generating documentation failed"
		HTML_DOCS=( "${S}/doc/html/" )
	fi

	cmake-utils_src_install

	cat <<-EOF > 99oxygen-gtk3
CONFIG_PROTECT="${EPREFIX}/usr/share/themes/oxygen-gtk/gtk-3.0"
EOF
	doenvd 99oxygen-gtk3
}
