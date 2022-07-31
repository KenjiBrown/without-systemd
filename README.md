# Without Systemd Gentoo Overlay

Use eselect repository to enable this overlay

```
eselect repository add without-systemd git https://github.com/KenjiBrown/without-systemd.git
```

## Issues: 
	`profiles/package.mask` can only mask packages in this overlay. A symbolic link to `/etc/portage/package/mask/` is needed to effectively mask Gentoo'systemd packages.

```
ln -svf /var/db/repos/without-systemd/profiles/package.mask /etc/portage/package.mask/without-systemd
```
