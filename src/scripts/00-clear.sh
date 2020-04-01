#!/busybox sh
[ -n $debug ] && clear
msg "Starting GNU/Linux"
[ ! -n $quiet ] && exec >/dev/null
