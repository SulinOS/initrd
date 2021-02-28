if [ "$debug" == "true" ] ; then
    copy_binary nano ldd strace
    ln -s /busybox ${WORKDIR}/xbin/bash
fi
echo "/busybox ash" > ${WORKDIR}/autorun/00-pause.sh