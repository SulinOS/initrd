[ -d "/rootfs/$subdir" ] || subdir="/"
debug "Subdir=$subdir"

[ "$init" != "" ] || init=/sbin/init
debug "init=$init"

if [ -f /rootfs/$subdir/etc/os-release ]; then
	msg "Wellcome to" "${C_PURPLE}$(cat /rootfs/$subdir/etc/os-release | grep '^NAME=' | head -n 1 | sed 's/^.*=//g')$C_CLEAR"
else
	msg "Wellcome to" "${C_PURPLE}GNU/Linux...${C_CLEAR}"
fi
sleep 2
if [ -f /rootfs/$subdir/etc/initrd.local ]; then
    inf "Running local initrd scripts"
    . /rootfs/$subdir/etc/initrd.local || true
fi
debug "Switching root"
exec env -i \
	"TERM=$TERM" \
	"LANG=$LANG"\
	"LC_ALL=$LANG"\
	switch_root "/rootfs/$subdir" $init "$@" || fallback_shell
