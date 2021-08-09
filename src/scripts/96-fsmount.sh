#!/busybox sh

common_boot(){
	debug "Moving mountpoints"
	for i in sys proc dev tmp run
	do
		mkdir /rootfs/$i 2>/dev/null || true
		mount --move /$i /rootfs/$i
	done
}
overlay_mount(){
	mkdir -p /root/a # upper
	mkdir -p /root/b # workdir
	mkdir -p /rootfs/
	umount /root/a 2>/dev/null
	umount /root/b 2>/dev/null
	if [ "$overlay" == "disable" ]; then
		warn "Overlayfs disabled"
		mount -t tmpfs -o size=100% none /rootfs
		inf "Please wait. Reading rootfs..."
		cp -prf /source/* /rootfs
		return 0
	fi
	debug "Creating overlayfs"
	mount -t overlay -o lowerdir=/source/,upperdir=/root/a,workdir=/root/b overlay /rootfs
	if [ "$overlay" == "zram" ]; then
		modprobe zram num_devices=2 2>/dev/null || true
		echo $memtotal > /sys/block/zram0/disksize
		echo $memtotal > /sys/block/zram1/disksize
		mkfs.ext2 /dev/zram0
		mkfs.ext2 /dev/zram1
		mount -t auto /dev/zram0 /root/a
		mount -t auto /dev/zram1 /root/b
	else
		mount -t tmpfs -o size=100% none /root/b
		mount -t tmpfs -o size=100% none /root/a
	fi
}

live_boot(){
	# load loop module
	if find /lib/modules | grep "/loop.ko$" ; then
	    modprobe loop ||fallback_shell
	fi
	[ "${sfs}" == "" ] && sfs="/main.sfs"
	if ! [ "${findiso}" == "" ] ; then
		msg "findiso variable available."
		sfs2="${sfs}"
		sfs="${findiso}"
	fi
	while [ "$root" == "" ] ; do
		list=$(ls /sys/class/block/ | grep ".*[0-9]$" | grep -v loop | grep -v ram | grep -v nbd | sed "s|^|/dev/|g")
		for part in $list
		do
			sleep 0.1
			debug "Looking for" "$part"
			if is_file_avaiable "$part" "${sfs}"
			then
				debug "Detected live media" "$part"
				export root=$part
			fi
		done
	done
	debug "Mounting live media"
	mkdir /output
	mkdir /source
	mount -t auto $root /output || fallback_shell
	if ! [ "$findiso" == "" ] ; then
		mkdir -p /iso-source || true
		mount /output/${sfs} /iso-source || fallback_shell
		mount /iso-source/${sfs2} /source || fallback_shell
	else
		mount /output/${sfs} /source || fallback_shell
	fi
	overlay_mount
	[ -d /output/merge ] && cp -prf /output/merge/* /rootfs/ &>/dev/null
	common_boot || fallback_shell
}
freeze_boot(){
	mkdir -p /source/ # lower
	debug "Mounting freeze media"
	mount -t auto -o defaults,rw $root /source
	overlay_mount
	[ -d /rootfs/home ] && mount --bind /source/home /rootfs/home
	[ -d /rootfs/data ] && mount --bind /source/data /rootfs/data
	common_boot || fallback_shell
}
image_boot(){
	mkdir -p /source/ # lower
	mkdir -p /rootfs
	debug "Mounting image"
	mount -t auto -o defaults,rw $root /source
	mount -t auto -o loop,rw,sync /source/$image /rootfs
	common_boot || fallback_shell
}

normal_boot(){
	debug "Mounting rootfs"
	mkdir -p /rootfs
	mkdir -p /newroot
	mount -t auto -o defaults,rw $root /newroot
	debug "Creating tmpfs for /"
	mount -t tmpfs tmpfs /rootfs
	for i in dev sys proc run tmp 
	do
		mkdir -p /rootfs/$i 2>/dev/null || true
	done
	debug "Creating binds"
	for i in boot bin lib32 etc kernel lib64 sbin usr data lib root var
	do
		debug "Binding" "/$i"
		mkdir -p /rootfs/$i
		mount --bind /newroot/$i /rootfs/$i
	done
	common_boot || fallback_shell
}


classic_boot(){
	debug "Mounting rootfs"
	mkdir -p /rootfs
	[ "$ro" == "" ] && ro=rw
	mount -t auto -o defaults,$ro $root /rootfs
	common_boot || fallback_shell
}
wait_device(){
msg "Waiting for $device"
	tmp=$(mktemp)
	rm -f $tmp
	mkdir $tmp
	while ! mount -t auto -o defaults,ro $root $tmp ; do
		sleep 0.1
	done
	umount -lf $tmp
}
msg "Searching filesystem"
[ -n "$debug" ] && /busybox ash
if [ "$boot" == "live" ]; then
	live_boot || fallback_shell
	msg "Booting from live-media" "($root)"
elif [ "$boot" == "normal" ]; then
	wait_device
	normal_boot || fallback_shell
	msg "Booting from" "$root"
elif [ "$boot" == "freeze" ]; then
	wait_device
	freeze_boot || fallback_shell
	msg "Booting from" "$root (freeze)"
elif [ "$boot" == "image" ]; then
	wait_device
	image_boot || fallback_shell
	msg "Booting from" "$root (image)"
else
	wait_device
	classic_boot || fallback_shell
	msg "Booting from" "$root (classic)"
fi
