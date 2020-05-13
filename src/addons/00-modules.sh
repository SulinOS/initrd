#!/bin/bash
[ ! -n "$KERNELVER"  ] && KERNELVER=$(uname -r)
[ ! -n "$MODDIR"  ] && MODDIR=/lib/modules/${KERNELVER}
[ -d $MODDIR ] || err "Module directory not found" "-> $MODDIR"

debug "Kernel Version" "${KERNELVER}"
debug "Module Directory" "${MODDIR}"
mkdir -p ${WORKDIR}/${MODDIR}
debug "Install main modules"
cp -prf ${MODDIR}/kernel/{crypto,fs,lib} ${WORKDIR}/${MODDIR}
debug "Install drivers"
cp -prf ${MODDIR}/kernel/drivers/{block,ata,md,firewire} ${WORKDIR}/${MODDIR}
cp -prf ${MODDIR}/kernel/drivers/{scsi,pcmcia,virtio} ${WORKDIR}/${MODDIR}
cp -prf ${MODDIR}/kernel/drivers/usb/{host,storage} ${WORKDIR}/${MODDIR}
if [ "$debug" != "true" ] ; then
	debug "Remove debug drivers"
	find ${WORKDIR}/${MODDIR} | grep debug | xargs rm -rf
fi
