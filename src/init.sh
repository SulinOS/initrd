#!/busybox ash
. /vars
. /functions
generate_rootfs
mount_handler
parse_cmdline
detect_root
run_modules
fallback_shell
