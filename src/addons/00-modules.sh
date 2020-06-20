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
