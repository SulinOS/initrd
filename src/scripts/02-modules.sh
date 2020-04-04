#!/busybox sh
debug "Listing kernel modules"
find  /lib/modules/ | sed "s/.*\///g" | grep "\.ko$" | sed "s/.ko$//g" | sed "s/^/modprobe /g"> /load_modules.sh
msg "Loading kernel modules"
sh /load_modules.sh 2> /dev/null | cat > /dev/null || fallback_shell

