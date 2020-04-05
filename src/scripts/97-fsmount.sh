#!/busybox sh

common_boot(){
	debug "Moving mountpoints"
	mount --move /sys /rootfs/sys
	mount --move /proc /rootfs/proc
	mount --move /dev /rootfs/dev
	mount --move /tmp /rootfs/tmp
	mount --move /run /rootfs/run
}
live_boot(){
	[ "$sfs" == "" ] && sfs="/main.sfs"
	list=$(ls /sys/class/block/ | grep ".*[0-9]$" | grep -v loop | grep -v ram | grep -v nbd | sed "s|^|/dev/|g")
	for part in $list
	do
		debug "Looking for $part"
		if is_file_avaiable "$part" "${sfs}"
		then
			debug "Detected live media: $part"
			export root=$part
		fi
		done
	mkdir -p /root/a # upper
	mkdir -p /root/b # workdir
	mkdir -p /rootfs/
	mkdir -p /source/ # lower
	mkdir -p /output
	debug "Mounting live media"
	mount -t auto $root /output
	mount /output/${sfs} /source
	umount /root/a 2>/dev/null
	umount /root/b 2>/dev/null
	debug "Creating overlayfs"
	mount -t overlay -o lowerdir=/source/,upperdir=/root/a/,workdir=/root/b overlay /rootfs
	mount -t tmpfs -o size=100% none /root/a
	mount -t tmpfs -o size=100% none /root/b
	common_boot || fallback_shell
}
freeze_mount(){
	mkdir -p /root/a # upper
	mkdir -p /root/b # workdir
	mkdir -p /rootfs/
	mkdir -p /source/ # lower
	debug "Mounting freeze media"
	mount -t auto $root /source
	umount /root/a 2>/dev/null
	umount /root/b 2>/dev/null
	debug "Creating overlayfs"
	mount -t overlay -o lowerdir=/source/,upperdir=/root/a/,workdir=/root/b overlay /rootfs
	mount -t tmpfs -o size=100% none /root/a
	mount -t tmpfs -o size=100% none /root/b
	common_boot || fallback_shell
}

normal_boot(){
	debug "Mounting rootfs"
	mkdir -p /rootfs
	mkdir -p /newroot
	mount -t auto $root /newroot
	debug "Creating tmpfs for /"
	mount -t tmpfs tmpfs /rootfs
	mkdir -p /rootfs/tmp
	mkdir -p /rootfs/run
	mkdir -p /rootfs/dev
	mkdir -p /rootfs/sys
	mkdir -p /rootfs/proc
	debug "Creating binds"
	for i in boot bin lib32 etc kernel lib64 sbin usr data lib root var
	do
		debug "Binding /$i"
		mkdir -p /rootfs/$i
		mount --bind /newroot/$i /rootfs/$i
	done
	common_boot || fallback_shell
}

classic_boot(){
	debug "Mounting rootfs"
	mkdir -p /rootfs
	mount -t auto $root /rootfs
	common_boot || fallback_shell
}

if [ "$boot" == "live" ]; then
	msg "Booting from live-media ($root)"
	live_boot || fallback_shell
elif [ "$boot" == "normal" ]; then
	msg "Booting from $root"
	normal_boot || fallback_shell
elif [ "$boot" == "freeze" ]; then
	msg "Booting from $root (freeze)"
	freeze_boot || fallback_shell
else
	msg "Booting from $root (classic)"
	classic_boot || fallback_shell
fi
