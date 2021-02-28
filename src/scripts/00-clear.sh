#!/busybox sh
[ -n $debug ] && clear
msg "Starting" "GNU/Linux"
if [ ! -n $quiet ] ; then
	exec >/dev/null
	exec 2>/dev/null
fi