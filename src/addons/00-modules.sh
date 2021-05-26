#!/bin/bash
[ "" == "$KERNELVER"  ] && KERNELVER=$(uname -r)
[ ! -n "$MODDIR"  ] && MODDIR=/lib/modules/${KERNELVER}
[ ! -n "$OUTPUT"  ] && OUTPUT=/boot/initrd.img-${KERNELVER}
[ -d $MODDIR ] || err "Module directory not found" "-> $MODDIR"
debug "Kernel Version" "${KERNELVER}"
debug "Module Directory" "${MODDIR}"
mkdir -p ${WORKDIR}/${MODDIR}
if [ "$allmodule" == true ] && [ "$skipglibc" != "true" ] && [ "$skipudev" != "true" ]; then
	cp -prf ${MODDIR}/* ${WORKDIR}/${MODDIR}
elif [ "$minimal" == true ]; then
	cp -prf ${MODDIR}/kernel/{crypto,fs,lib,block} ${WORKDIR}/${MODDIR}
	cp -prf ${MODDIR}/kernel/drivers/input/{keyboard,serio} ${WORKDIR}/${MODDIR}
	cp -prf ${MODDIR}/kernel/drivers/{ata,md,mmc,firewire} ${WORKDIR}/${MODDIR}
	cp -prf ${MODDIR}/kernel/drivers/{scsi,pcmcia,virtio} ${WORKDIR}/${MODDIR}
	cp -prf ${MODDIR}/kernel/drivers/usb/ ${WORKDIR}/${MODDIR}
	cp -prf ${MODDIR}/kernel/drivers/acpi/ ${WORKDIR}/${MODDIR}
	# Some kernels not have this directories.
	cp -prf ${MODDIR}/kernel/drivers/{block,cdrom}/ ${WORKDIR}/${MODDIR} || true
else
	debug "Install main modules"
	cp -prf ${MODDIR}/kernel/{crypto,fs,lib} ${WORKDIR}/${MODDIR}
	debug "Install drivers"
	cp -prf ${MODDIR}/kernel/drivers/* ${WORKDIR}/${MODDIR}
	debug "Remove useless module"
	rm -rf ${WORKDIR}/${MODDIR}/{gpu,net}
	if [ "$debug" != "true" ] ; then
		debug "Remove debug drivers"
		find ${WORKDIR}/${MODDIR} | grep debug | xargs rm -rf
	fi
fi
find  ${WORKDIR}/lib/modules/* | grep ".ko.xz" | xargs xz -d &> /dev/null || true
find  ${WORKDIR}/lib/modules/* | grep ".ko.gz" | xargs gzip -d &> /dev/null || true
