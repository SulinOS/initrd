if [ -f /new_root/etc/os-release ]; then
	msg "Wellcome to $(cat /new_root/etc/os-release | grep '^NAME=' | head -n 1 | sed 's/^.*=//g')"
else
	msg "Wellcome to GNU/Linux..."
fi

[ -d "/new_root/$subdir" ] || subdir="/"
debug "Subdir=$subdir"

[ ! -n $init ] || init=/sbin/init
debug "init=$init"

if [ -f /new_root/$subdir/etc/initrd.local ]; then
    msg "Running local initrd scripts"
    . /new_root/$subdir/etc/initrd.local || true
fi

debug "Switching root"
exec env -i \
	"TERM=$TERM" \
	switch_root "/rootfs/$subdir" $init "$@" || fallback_shell
