#!/busybox sh
msg "Running fsck"
mkdir /etc/
touch /etc/fstab
fsck -Ta -y -t $rootfstype "$root" 2>/dev/null
