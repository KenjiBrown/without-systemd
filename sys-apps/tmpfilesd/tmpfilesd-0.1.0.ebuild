# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit tmpfiles

if [[ ${PV} = 9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/juur/${PN}"
else
	SRC_URI="https://github.com/juur/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc ~x86"
fi

DESCRIPTION="systemd-tmpfiles replacement; includes support for sysvinit style enviroments"
HOMEPAGE="https://github.com/juur/tmpfilesd"

LICENSE="MIT"
SLOT="0"

src_prepare() {
	default
	sed -i -e "/tmpfiles-d/d" Makefile.in || die
}

src_configure()  {
	econf --bindir="${EPREFIX}"/bin
}

src_install() {
	emake DESTDIR="${ED}" install
	einstalldocs
	cd misc
	dotmpfiles tmpfiles-d/etc.conf # Sets /etc/localtime to UTC
	dotmpfiles tmpfiles-d/legacy.conf # Not sure if this is needed
	dotmpfiles tmpfiles-d/sap.conf # harmless if not using sap; Consider USE=sap
	#dotmpfiles tmpfiles-d/systemd-nologin.conf # should be provided by systemd
	#dotmpfiles tmpfiles-d/systemd.conf # should be provided by systemd
	dotmpfiles tmpfiles-d/tmp.conf # harmless
	dotmpfiles tmpfiles-d/var.conf # changed permissions should be investigated
	dotmpfiles tmpfiles-d/x11.conf # Xorg creates these. Consider USE=X
	exeinto /etc/cron.daily
	doexe "${FILESDIR}"/tmpfilesd-clean
	for f in tmpfilesd-dev tmpfilesd-setup; do
		newconfd tmpfilesd.sysconfig ${f}
		newinitd "${FILESDIR}/${f}.initd" ${f}
	done
}

add_service() {
	local initd=$1
	local runlevel=$2

	elog "Auto-adding '${initd}' service to your ${runlevel} runlevel"
	mkdir -p "${EROOT}"etc/runlevels/${runlevel}
	ln -snf /etc/init.d/${initd} "${EROOT}"etc/runlevels/${runlevel}/${initd}
}

pkg_postinst() {
	tmpfiles_process etc.conf
	tmpfiles_process legacy.conf
	tmpfiles_process sap.conf
	#tmpfiles_process systemd-nologin.conf # should be provided by systemd
	#tmpfiles_process systemd.conf # should be provided by systemd
	tmpfiles_process tmp.conf 
	tmpfiles_process var.conf
	tmpfiles_process x11.conf
	if [[ -z $REPLACING_VERSIONS ]]; then
		add_service tmpfilesd-dev sysinit
		add_service tmpfilesd-setup boot
	fi
}
