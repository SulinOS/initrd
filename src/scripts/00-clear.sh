#!/busybox sh
[ -n $debug ] && clear
msg "Starting SulinOS"
[ ! -n $quiet ] && exec >/dev/null
