#!/busybox sh
debug "Listing kernel modules"
find  /lib/modules/ | sed "s/.*\///g" | grep "\.ko$" | sed "s/.ko$/ &/g" | sed "s/^/modprobe /g"> /load_modules.sh
msg "Trying to load kernel modules"
sh /load_modules.sh 1>/dev/null 2>&1
msg "Waiting for kernel modules"
sleep 3
