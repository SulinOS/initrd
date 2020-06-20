if [ "$skipglibc" != "true" ] && [ "$skipudev" != "true" ] ; then
  #generate module stuff
  cp ${MODDIR}/modules.{builtin,order} ${WORKDIR}/${MODDIR}
  depmod -b ${WORKDIR} ${KERNELVER}
  #creating dirs
  mkdir -p ${WORKDIR}/etc/udev/
  mkdir -p ${WORKDIR}/etc/modprobe.d/
  # copy rules and files
  if [ -d /lib/udev ]; then
    cp -a /lib/udev ${WORKDIR}/lib
  fi
  if [ -d /lib/systemd ]; then
    cp -a /lib/systemd ${WORKDIR}/lib
  fi
  if [ -f /etc/udev/udev.conf ]; then
   cp /etc/udev/udev.conf ${WORKDIR}/etc/udev/udev.conf
  fi
  for file in $(find /etc/udev/rules.d/ -type f) ; do
    cp $file $WDIR/etc/udev/rules.d
  done
  touch ${WORKDIR}/etc/modprobe.d/modprobe.conf
  #copy binaries
  copy_binary udevadm udevd tmpfiles vgscan  vschange
else
	warn "udev will not install"
fi
