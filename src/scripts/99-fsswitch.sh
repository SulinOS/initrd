[ -d "/rootfs/$subdir" ] || subdir="/"
debug "Subdir=$subdir"

[ "$init" != "" ] || init=/sbin/init
debug "init=$init"

if [ -f /rootfs/$subdir/etc/os-release ]; then
	msg "Wellcome to" "${C_PURPLE}$(cat /rootfs/$subdir/etc/os-release | grep '^NAME=' | head -n 1 | sed 's/^.*=//g')$C_CLEAR"
else
	msg "Wellcome to" "${C_PURPLE}GNU/Linux...${C_CLEAR}"
fi
if [ -f /rootfs/$subdir/etc/initrd.local ]; then
    inf "Running local initrd scripts"
    . /rootfs/$subdir/etc/initrd.local || true
fi
initrd_boot(){
	mv busybox /bin/busybox
	/bin/busybox rm -f * || true
	/bin/busybox mv /bin/busybox /busybox
	rm -rf autorun scripts lib || true
	for i in boot lib32 etc kernel lib64 sbin usr data lib root var home opt srv bin
	do
		if [ -d /rootfs/$subdir/$i ] ; then
			msg "Binding" "/$i"
			mkdir -p /$i || true
			mount --bind /rootfs/$subdir/$i /$i || true
		fi
	done
	rm -f /busybox
	exec env -i "TERM=$TERM" "LANG=$LANG" "LC_ALL=$LANG" $init "$@"
}
if [ "$boot" == "live" ] ; then
    initrd_boot
fi
debug "Switching root"
exec env -i \
	"TERM=$TERM" \
	"LANG=$LANG"\
	"LC_ALL=$LANG"\
	switch_root "/rootfs/$subdir" $init "$@" || fallback_shell
