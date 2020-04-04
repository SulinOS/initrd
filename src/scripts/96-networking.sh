#Thanks for mll: https://github.com/ivandavidov/minimal
msg "Trying to connect network."
for DEVICE in /sys/class/net/* ; do
  inf "Found network device ${DEVICE##*/}"
  ip link set ${DEVICE##*/} up
  [ ${DEVICE##*/} != lo ] && udhcpc -b -i ${DEVICE##*/} -s /etc/05_rc.dhcp
done
