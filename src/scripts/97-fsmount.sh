#!/busybox sh

common_boot(){
	debug "Moving mountpoints"
	mount --move /sys /rootfs/sys
	mount --move /proc /rootfs/proc
	mount --move /dev /rootfs/dev
	mount --move /tmp /rootfs/tmp
	mount --move /run /rootfs/run
}
overlay_mount(){
	mkdir -p /root/a # upper
	mkdir -p /root/b # workdir
	mkdir -p /rootfs/
	umount /root/a 2>/dev/null
	umount /root/b 2>/dev/null
	debug "Creating overlayfs"
	mount -t overlay -o lowerdir=/source/,upperdir=/root/a,workdir=/root/b overlay /rootfs
	if [ "$overlay" == "zram" ]; then
		modprobe zram num_devices=1 2>/dev/null || true
		echo $(($memtotal)) > /sys/block/zram0/disksize
		sh
		mkfs.ext2 /dev/zram0
		mount -t auto /dev/zram0 /root/a
		mount -t tmpfs -o size=100% none /root/b
	else
		mount -t tmpfs -o size=100% none /root/b
		mount -t tmpfs -o size=100% none /root/a
	fi
}
live_boot(){
	[ "$sfs" == "" ] && sfs="/main.sfs"
	list=$(ls /sys/class/block/ | grep ".*[0-9]$" | grep -v loop | grep -v ram | grep -v nbd | sed "s|^|/dev/|g")
	for part in $list
	do
		debug "Looking for" "$part"
		if is_file_avaiable "$part" "${sfs}"
		then
			debug "Detected live media" "$part"
			export root=$part
		fi
		done
	debug "Mounting live media"
	mount -t auto $root /output
	mount /output/${sfs} /source
	overlay_mount
	[ -d /output/merge ] && cp -prfv /output/merge/* /rootfs/
	common_boot || fallback_shell
}
freeze_boot(){
	mkdir -p /source/ # lower
	debug "Mounting freeze media"
	mount -t auto -o defaults,ro $root /source
	overlay_mount
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

if [ "$boot" == "live" ]; then
	msg "Booting from live-media" "($root)"
	live_boot || fallback_shell
elif [ "$boot" == "normal" ]; then
	msg "Booting from" "$root"
	normal_boot || fallback_shell
elif [ "$boot" == "freeze" ]; then
	msg "Booting from" "$root (freeze)"
	freeze_boot || fallback_shell
else
	msg "Booting from" "$root (classic)"
	classic_boot || fallback_shell
fi
