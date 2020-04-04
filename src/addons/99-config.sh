[ "$CONFIG" != "" ] || CONFIG=/etc/initrd.conf
debug "Using config: $CONFIG"
mkdir -p ${WORKDIR}/etc
if [ -f $CONFIG ] ; then
   cat ${CONFIG} > ${WORKDIR}/etc/initrd.conf
else
    echo > ${WORKDIR}/etc/initrd.conf
fi
