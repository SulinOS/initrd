#!/busybox sh
generate_rootfs(){
	msg "Creating initrd"
	/busybox mkdir /bin
	/busybox mkdir /sys
	/busybox mkdir /proc
	/busybox mkdir /tmp
	/busybox mkdir /run
	/busybox --install -s /bin
	/busybox mknod /dev/misc/rtc0 c 254 0 2>/dev/null
	/busybox mdev -s 2>/dev/null
}
run_modules(){
	for i in $(ls /scripts | sort)
	do
		. /scripts/$i
	done
}
mount_handler(){
	msg "Mount handler running"
	/busybox mount -t devtmpfs dev /dev || true
	/busybox mount -t proc proc /proc || true
	/busybox mount -t sysfs sys /sys || true
	/busybox mount -t tmpfs tmpfs /tmp || true
	/busybox mount -t tmpfs tmpfs /run || true
}
parse_cmdline(){
	for i in $(cat /proc/cmdline)
	do
		export $i
	done
}
start_dmesg(){
	msg "Starting dmesg"
	/busybox dmesg -n 1 || true
}
msg() {
    echo -e " ${C_GREEN}*${C_CLEAR} ${@}"
}
debug() {
    [ ! -n "$debug"  ] || echo -e " ${C_BLUE}*${C_CLEAR} ${@}"
}

warn() {
    echo -e " ${C_YELLOW}*${C_CLEAR} ${@}"
}

err() {
    echo -e " ${C_RED}*${C_CLEAR} ${@}"
}

is_file_avaiable(){
    disktmp=$(mktemp)
    rm -rf $disktmp
    mkdir -p $disktmp || true 
    mount -t auto "$1" $disktmp 2>/dev/null
    [ -f "$disktmp/$2" ] && [ -b "$1" ]
    status=$?
    umount $disktmp 2>/dev/null
    return $status
}

fallback_shell(){
	/busybox setsid cttyhack /bin/sh || /busybox sh	
}
detect_root(){
	msg "Detecting real root"
	read -r cmdline < /proc/cmdline
	for param in $cmdline ; do
		case $param in
			init=*      ) init=${param#init=}             ;;
			root=*      ) root=${param#root=}             ;;
			rootdelay=* ) rootdelay=${param#rootdelay=}   ;;
			rootfstype=*) rootfstype=${param#rootfstype=} ;;
			rootflags=* ) rootflags=${param#rootflags=}   ;;
			resume=*    ) resume=${param#resume=}         ;;
			noresume    ) noresume=true                   ;;
			ro          ) ro="ro"                         ;;
			rw          ) ro="rw"                         ;;
			esac
	done
	case "$root" in
		/dev/* ) device=$root ;;
		UUID=* ) eval $root; device="/dev/disk/by-uuid/$UUID"  ;;
		LABEL=*) eval $root; device="/dev/disk/by-label/$LABEL" ;;
		""     ) err "No root device specified." 
			 echo -ne "\033[33;1mWhere is the root>\033[;0m"; read root ;;
	esac
	export root
	export rootfstype
	export init
}
