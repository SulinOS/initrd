[ "$CONFIG" != "" ] || CONFIG=/etc/initrd.conf
debug "Using config" "$CONFIG"
mkdir -p ${WORKDIR}/etc
if [ -f $CONFIG ] ; then
   cat ${CONFIG} > ${WORKDIR}/etc/initrd.conf
else
    echo "LANG=$LANG" > ${WORKDIR}/etc/initrd.conf
fi
