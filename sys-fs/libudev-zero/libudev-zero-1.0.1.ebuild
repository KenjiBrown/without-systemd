# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Drop-in replacement for libudev intended to work with any device manager"
HOMEPAGE="https://github.com/illiliti/libudev-zero"
SRC_URI="https://github.com/illiliti/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="ISC"
SLOT="0"
KEYWORDS="alpha amd64 arm arm64 hppa ia64 loong m68k mips ppc ppc64 riscv s390 sparc x86"

DEPEND=" !sys-apps/systemd-utils[udev] !sys-fs/eudev !sys-fs/udev "
RDEPEND="${DEPEND}"
BDEPEND=""

src_install() {
	PREFIX=${ED}/usr
	case ${ARCH} in
		"amd64")
		LIBDIR="${PREFIX}/lib64"
		;;
		"arm64")
		LIBDIR="${PREFIX}/lib64"
		;;
		"ia64")
		LIBDIR="${PREFIX}/lib64"
		;;
		"ppc64")
		LIBDIR="${PREFIX}/lib64"
		;;
		*)
		LIBDIR="${PREFIX}/lib"
		;;
	esac
	einfo "PREFIX=${PREFIX} LIBDIR=${LIBDIR}"
	make PREFIX=${PREFIX} LIBDIR=${LIBDIR} install
}
