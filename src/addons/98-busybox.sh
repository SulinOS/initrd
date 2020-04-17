bb=$(which busybox)
if [ -f "$bb" ] ; then
	if LANG="C" ldd $bb | grep "not a dynamic executable" >/dev/null ; then
		debug "Install busybox" "$bb"
		install $bb $WORKDIR/busybox >/dev/null
	elif [ "$skipglibc" != "true" ] ; then
		err "Busybox is not a static binary"
		exit 1
	else
		copy_binary busybox
	fi
else
	err "Busybox not found"
	exit 1
fi
