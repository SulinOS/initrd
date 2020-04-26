#!/busybox ash
tmpfile="/rootfs/$subdir/etc/initrd.remove"
rmv(){
	while read line
	do
		if [ -f "$line" ] || [ -d "$line" ]; then
			rm -rvf -- "$line"
		fi
	done
}
if [ -f "$tmpfile" ] ; then
	cat "$tmpfile" | rmv
	rm -f "$tmpfile"
	touch "$tmpfile" 2>/dev/null || true
fi
homedir=/rootfs/$subdir/data/user/
[ -d $homedir ] || homedir=/rootfs/$subdir/home
if [ -d  $homedir ] ; then
	for user in $(ls $homedir)
	do
		rm -rf $homedir/$user/.cache
	done
fi
