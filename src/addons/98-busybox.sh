bb=$(which busybox)
if [ -f "$bb" ] ; then
	if LANG="C" ldd $bb | grep "not a dynamic executable" >/dev/null ; then
		debug "Install busybox" "$bb"
		install $bb $WORKDIR/busybox >/dev/null
	elif [ "$skipglibc" != "false" ] ; then
		copy_binary busybox
	else
		err "Busybox is not a static binary"
		exit 1
	fi
else
	err "Busybox not found"
	exit 1
fi
