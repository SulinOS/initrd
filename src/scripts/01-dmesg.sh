inf "Starting" "dmesg"
/busybox dmesg -n 1 || true
[ -n $debug ] || dmesg -w &