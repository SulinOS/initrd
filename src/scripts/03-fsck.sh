#!/busybox sh
inf "Running fsck"
fsck -Ta -y -t $rootfstype "$root" 2>/dev/null
