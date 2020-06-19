#!/busybox sh
msg "Loading filesystem drivers"
ls /lib/modules/*/fs/ | sed "s/^/modprobe /g" | sed "s/$/ &/g" > /fs
sh /fs &>/dev/null
if [ -x /xbin/udevd -a -x /xbin/udevadm ] && [ "$noudev" != "true" ]; then
  msg "Triggering udev"
  /xbin/udevd --daemon
  /xbin/udevadm trigger --action=add
  /xbin/udevadm settle --timeout=10
else
  debug "Listing kernel modules"
  find  /lib/modules/ | sed "s/.*\///g" | grep "\.ko" | sed "s/.ko.*/ &/g" | sed "s/^/modprobe /g"> /load_modules.sh
  msg "Trying to load kernel modules"
  sh /load_modules.sh &>/dev/null
fi
msg "Waiting for kernel modules"
sleep 2
