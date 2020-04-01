#!/busybox sh
generate_rootfs(){
	msg "Creating initrd"
	/busybox mkdir /bin
	/busybox mkdir /sys
	/busybox mkdir /proc
	/busybox mkdir /tmp
	/busybox mkdir /run
	/busybox --install -s /bin
	/busybox mdev -s 2>/dev/null
}
run_modules(){
	for i in $(ls /scripts | sort)
	do
		debug "Running $i"
		. /scripts/$i || true
	done
}
mount_handler(){
	msg "Mount handler running"
	/busybox mount -t devtmpfs dev /dev || true
	/busybox mount -t proc proc /proc   || true
	/busybox mount -t sysfs sys /sys    || true
	/busybox mount -t tmpfs tmpfs /tmp  || true
	/busybox mount -t tmpfs tmpfs /run  || true
	if [ -e /sys/firmware/efi ]; then
		msg "UEFI mode detected."
		mount -t efivarfs efivarfs /sys/firmware/efi/efivars -o nosuid,nodev,noexec
	fi
}
parse_cmdline(){
	for i in $(cat /proc/cmdline)
	do
		export $i
	done
}

is_file_avaiable(){
    disktmp=$(mktemp)
    rm -f $disktmp
    mkdir -p $disktmp || true 
    mount -t auto "$1" $disktmp 2>/dev/null
    [ -f "$disktmp/$2" ] && [ -b "$1" ]
    status=$?
    umount -lf $disktmp 2>/dev/null
    return $status
}

fallback_shell(){
	while true
	do
		warn "Booting dead. Now you are in initial ramdisk."
		/busybox setsid cttyhack /bin/sh || /busybox sh
		clear
	done
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
