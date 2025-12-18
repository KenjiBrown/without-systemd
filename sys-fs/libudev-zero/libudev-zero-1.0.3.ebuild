# Copyright 2021-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit multilib-minimal toolchain-funcs

DESCRIPTION="Daemonless replacement for libudev"
HOMEPAGE="https://github.com/illiliti/libudev-zero"
SRC_URI="
	https://github.com/illiliti/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz
"

LICENSE="ISC"
SLOT="0/$(ver_cut 1)"
KEYWORDS="~alpha amd64 arm arm64 ~hppa ~ia64 ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86"

DEPEND="
	!sys-apps/systemd-utils[udev]
"
RDEPEND="${DEPEND}"

IUSE="+hotplug static static-libs"

cc_info() {
	tc-export_build_env
	local cflags=(
		${BUILD_CFLAGS}
		${BUILD_LDFLAGS}
		${BUILD_CPPFLAGS}
	)

	set -- "$(tc-getCC)" "${cflags[@]}" "${@}"
	einfo "${*}"
	"${@}"
}

src_prepare() {
	default

	use static-libs || {
		sed -i Makefile \
			-e '/^all:/s/libudev.a//' \
			-e '/^install:/s/\w\+-static//' \
		|| die
	}

	multilib_copy_sources
}

multilib_src_compile() {
	emake

	if use hotplug && multilib_is_native_abi; then
		cc_info $(usex static -static '') contrib/helper.c -o "${PN}-helper"
	fi
}

multilib_src_install() {
	emake install \
		DESTDIR="${D}" \
		PREFIX="${EPREFIX}/usr" \
		LIBDIR="${EPREFIX}/usr/$(get_libdir)"

	if use hotplug && multilib_is_native_abi; then
		dobin "${PN}-helper"
	fi
}

multilib_src_install_all() {
	if use hotplug && multilib_is_native_abi; then
		insinto "/usr/share/doc/${P}/examples"
		sed "s;/path/to/helper;${PN}-helper;g" contrib/mdev.conf \
			| newins - mdev.conf
	fi
}
