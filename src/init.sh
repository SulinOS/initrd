#!/busybox ash
. /vars
. /functions
generate_rootfs || fallback_shell
mount_handler || fallback_shell
parse_cmdline || fallback_shell
detect_root || fallback_shell
run_modules || fallback_shell
while true
do
 /busybox sleep 999
done
