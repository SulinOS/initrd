[ "$CONFIG" != "" ] || CONFIG=/etc/initrd.conf
echo -e "  \033[34;1mUsing config:\033[;0m $CONFIG"
mkdir -p ${WORKDIR}/etc
if [ -f $CONFIG ] ; then
   cat ${CONFIG} > ${WORKDIR}/etc/initrd.conf
else
    echo > ${WORKDIR}/etc/initrd.conf
fi
