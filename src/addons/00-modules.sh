#!/bin/bash
[ ! -n "$KERNELVER"  ] && KERNELVER=$(uname -r)
[ ! -n "$MODDIR"  ] && MODDIR=/lib/modules/${KERNELVER}
if [ ! -d $MODDIR ] ; then
	echo -e "\033[31;1mModule directory not found"
	echo -e "  ->$MODDIR\033[;0m"
	exit 1
fi
echo -e "  \033[34;1mKernel Version:\033[;0m ${KERNELVER}"
echo -e "  \033[34;1mModule Directory:\033[;0m ${MODDIR}"
mkdir -p ${WORKDIR}/${MODDIR}
echo -e "  \033[34;1mInstall:\033[;0m main modules"
cp -prf ${MODDIR}/kernel/{crypto,fs,lib} ${WORKDIR}/${MODDIR}
echo -e "  \033[34;1mInstall:\033[;0m drivers"
cp -prf ${MODDIR}/kernel/drivers/{block,ata,md,firewire} ${WORKDIR}/${MODDIR}
cp -prf ${MODDIR}/kernel/drivers/{scsi,pcmcia,virtio} ${WORKDIR}/${MODDIR}
cp -prf ${MODDIR}/kernel/drivers/usb/{host,storage} ${WORKDIR}/${MODDIR}
