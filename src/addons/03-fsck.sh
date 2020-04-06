if [ "$skipfsck" != "true" ] && [ "$skipglibc" != "true" ] ; then
	copy_binary fsck fsck.{ext2,ext3,ext4,btrfs}
else
	warn "fsck will not install"
fi
