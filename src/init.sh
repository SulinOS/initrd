#!/busybox ash
. /vars
. /etc/initrd.conf
. /common
. /functions
generate_rootfs
mount_handler
parse_cmdline
detect_root
run_modules
fallback_shell
