#!/busybox sh
msg "Loading filesystem drivers"
ls /lib/modules/*/fs/ | sed "s/^/modprobe /g" | sed "s/\.ko//g" | sed "s/$/ &/g" > /fs
sh /fs &>/dev/null
msg "Loading crypto drivers"
ls /lib/modules/*/crypto/ | sed "s/^/modprobe /g" | sed "s/\.ko//g" | sed "s/$/ &/g" > /crypto
sh /crypto &>/dev/null

load_modules(){
  debug "Listing kernel modules"
  cd /lib/modules/*
  find  crypto lib block ata md firewire scsi \
     message pcmcia virtio host storage \
     -type f 2> /dev/null | sed "s/.*\///g" | grep "\.ko" | sed "s/.ko.*/ &/g" | sed "s/^/modprobe /g"> /load_modules.sh
  msg "Trying to load kernel modules"
  sh /load_modules.sh &>/dev/null
}

if [ -x /xbin/udevd -a -x /xbin/udevadm ] && [ -n "$noudev" ]; then
  msg "Triggering udev"
  mdev -s
  {
  /xbin/udevd --daemon
  /xbin/udevadm trigger --action=add --type=subsystems
  /xbin/udevadm trigger --action=add --type=devices
  /xbin/udevadm trigger --action=change --type=devices
  /xbin/udevadm settle
  } || load_modules
  vgscan --mknodes --ignorelockingfailure >/dev/null 2>&1
  vgchange --sysinit --activate y >/dev/null 2>&1

else
  warn "Eudev not found or disabled"
  load_modules
fi

