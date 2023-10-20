# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit prefix

if [[ ${PV} = 9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/juur/${PN}"
fi

DESCRIPTION="systemd-tmpfiles replacement; includes support for sysvinit style enviroments"
HOMEPAGE="https://github.com/juur/tmpfilesd"

LICENSE="MIT"
SLOT="0"


src_install() {
	emake DESTDIR="${ED}" install
	einstalldocs
	cd misc
	insinto /etc/cron.daily
	doexe "${FILESDIR}/tmpfilesd-clean"
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
	if [[ -z $REPLACING_VERSIONS ]]; then
		add_service tmpfilesd-dev sysinit
		add_service tmpfilesd-setup boot
	fi
}
