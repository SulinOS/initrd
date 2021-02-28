#!/busybox sh
[ "$boot" == "live" ] && return 0
if [ -f /xbin/fsck ] ; then
	inf "Running" "fsck"
	touch /etc/mtab
	touch /etc/fstab
	if [ "${fsck_force}" == "true" ] ; then
		/xbin/fsck "$root" -y -f &>/dev/null
	else
		/xbin/fsck "$root" -y &>/dev/null
	fi
else
	warn "fsck not found"
fi
