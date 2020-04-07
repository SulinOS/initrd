# for install
`make install DESTDIR=/`

# basic usage
`update-initrd KERNELVER=xxxx MODDIR=/lib/modules/xxxx OUTPUT=/boot/initrd.img-xxxx`

# boot modes
```
boot=classic    : Booting from installed system
boot=normal     : Booting from installed system but / as tmpfs (All directories binded)
boot=live       : Live boot mode. Search main.sfs (see also sfs=xxx) file and mount overlayfs
boot=freeze     : Frozen mode. Booting from installed system but / as overlayfs (changes never saved)
```
# boot parameters
```
sfs=xxx         : Search xxx and used for booting from live rootfs
LANG=xxx        : Change language (initrd and system)
root=xxx        : Change rootfs localion or uuid
overlay=zram    : Live boot mode uses zram0 as tmpfs (experimental)
overlay=disable : Live boot mode does not use overlayfs (dangerous)
debug           : Write debug logs
quiet           : No output mode (Only error logs writed)
ro              : mount filesystem as read-only
rw              : mount filesystem as read-write
```

