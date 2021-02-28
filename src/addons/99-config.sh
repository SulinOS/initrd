inf "Using config" "$CONFIG"
mkdir -p ${WORKDIR}/etc
if [ -f $CONFIG ] ; then
   cat ${CONFIG} > ${WORKDIR}/etc/initrd.conf
else
    echo "debug=$debug" >> ${WORKDIR}/etc/initrd.conf
    echo "nocolor=$nocolor" >> ${WORKDIR}/etc/initrd.conf
fi
