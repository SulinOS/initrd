#!/busybox sh
[ "$boot" == "live" ] && return 0
if [ -f /xbin/fsck ] ; then
	inf "Running" "fsck"
	touch /etc/mtab
	touch /etc/fstab
	/xbin/fsck.$rootfstype -f -y "$root" || true
else
	warn "fsck not found"
fi
