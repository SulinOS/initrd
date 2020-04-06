#Thanks for mll: https://github.com/ivandavidov/minimal
msg "Trying to connect network"
for DEVICE in /sys/class/net/* ; do
  inf "Found network device" "${DEVICE##*/}" || true
  ip link set ${DEVICE##*/} up || true
  [ ${DEVICE##*/} != lo ] && udhcpc -b -i ${DEVICE##*/} -s /etc/05_rc.dhcp || true
done
