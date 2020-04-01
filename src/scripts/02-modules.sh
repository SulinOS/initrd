#!/busybox sh
find  /lib/modules/ | sed "s/.*\///g" | grep "\.ko$" | sed "s/.ko$//g" | sed "s/^/modprobe /g"> /load_modules.sh
sh /load_modules.sh 2> /dev/null | cat > /dev/null

msg "Loading kernel modules"
