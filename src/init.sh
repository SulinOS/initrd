#!/busybox ash
. /vars
. /functions
generate_rootfs
start_dmesg
mount_handler
parse_cmdline
detect_root
run_modules
while true
do
 /busybox sleep 999
done
