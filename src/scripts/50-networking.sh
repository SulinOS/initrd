#Thanks for mll: https://github.com/ivandavidov/minimal
[ ! -n "${initrd-network}" ] || return 0
msg "Trying to connect network"
for DEVICE in /sys/class/net/* ; do
	inf "Network device" $DEVICE
	ip link set ${DEVICE##*/} up || true
	[ ${DEVICE##*/} != lo ] && udhcpc -b -i ${DEVICE##*/} -s /etc/05_rc.dhcp || true
done

