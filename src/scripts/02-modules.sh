#!/busybox sh
if [ -x /xbin/udevd -a -x /xbin/udevadm ]; then
  msg "Triggering udev"
  /xbin/udevd --daemon
  /xbin/udevadm trigger --action=add
  /xbin/udevadm settle --timeout=10
else
  debug "Listing kernel modules"
  find  /lib/modules/ | sed "s/.*\///g" | grep "\.ko" | sed "s/.ko.*/ &/g" | sed "s/^/modprobe /g"> /load_modules.sh
  msg "Trying to load kernel modules"
  sh /load_modules.sh &>/dev/null
  msg "Waiting for kernel modules"
  sleep 2
fi
