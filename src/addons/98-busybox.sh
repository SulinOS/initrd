bb=$(which busybox)
if [ -f "$bb" ] ; then
	set +e
        bbdyn=$(LANG="C" ldd $bb | grep "not a dynamic executable" 2>&1 )
	if [ $? -ne 0 ] || [ "$bbdyn" != "" ] ; then
		debug "Install busybox" "$bb"
		install $bb $WORKDIR/busybox >/dev/null
	elif [ "$skipglibc" != "true" ] ; then
		err "Busybox is not a static binary"
		exit 1
	else
		copy_binary busybox
	fi
	set -e
else
	err "Busybox not found"
	exit 1
fi
