#!/busybox sh
live_boot(){
	list=$(ls /sys/class/block/ | grep ".*[0-9]$" | grep -v loop | grep -v ram | grep -v nbd | sed "s|^|/dev/|g")
	for part in $list
	do
		if is_file_avaiable "$part" "main.sfs"
		then
			export root=$part
		fi
		done
	mkdir -p /rootfs/a # upper
	mkdir -p /rootfs/b # workdir
	mkdir -p /live_root/
	mkdir -p /source/ # lower
	mkdir -p /output
	echo -e "Rootfs:\033[32;1m $root\033[;0m"
	mount -t auto $root /output
	mount /output/main.sfs /source
	umount /rootfs/a 2>/dev/null
	umount /rootfs/b 2>/dev/null
	mount -t overlay -o lowerdir=/source/,upperdir=/rootfs/a/,workdir=/rootfs/b overlay /live_root
	mount -t tmpfs -o size=100% none /rootfs/a
	mount -t tmpfs -o size=100% none /rootfs/b
	mount --move /sys /live_boot/sys
	mount --move /proc /live_boot/proc
	mount --move /dev /live_boot/dev
	mount --move /tmp /live_boot/tmp
	mount --move /run /live_boot/run
	exec switch_root /live_root /sbin/init "$@" || /busybox sh
}
normal_boot(){
	mkdir -p /rootfs
	mkdir -p /newroot
	mount -t auto $root /newroot
	mount -t tmpfs tmpfs /rootfs
	mkdir -p /rootfs/tmp
	mkdir -p /rootfs/run
	ln -s kernel/dev /rootfs/dev
	ln -s kernel/sys /rootfs/sys
	ln -s kernel/proc /rootfs/proc
	for i in boot bin lib32 etc kernel lib64 sbin usr data lib root var
	do
		mkdir -p /rootfs/$i
		mount --bind /newroot/$i /rootfs/$i
	done
	
	mount --move /sys /rootfs/kernel/sys
	mount --move /proc /rootfs/kernel/proc
	mount --move /dev /rootfs/kernel/dev
	mount --move /tmp /rootfs/tmp
	mount --move /run /rootfs/run
	exec switch_root /rootfs /sbin/init "$@" || /busybox sh
}

clasic_boot(){
	mkdir -p /rootfs
	mount -t auto $root /newroot
	mount --move /sys /rootfs/kernel/sys
	mount --move /proc /rootfs/kernel/proc
	mount --move /dev /rootfs/kernel/dev
	mount --move /tmp /rootfs/tmp
	mount --move /run /rootfs/run
	exec switch_root /rootfs /sbin/init "$@" || /busybox sh
}
if [ "$boot" == "live" ]; then
	msg "Booting from live-media"
	live_boot
fi
if [ "$boot" == "classic" ]; then
	msg "Booting from $root (classic)"
	clasic_boot
else
	msg "Booting from $root"
	normal_boot
fi
