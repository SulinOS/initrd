#!/bin/bash
export src=/lib/initrd/
export WORKDIR=$(mktemp)
export OUTPUT=/boot/initrd.img-$(uname -r)
for i in $*
do
	export $i
done
rm -f $WORKDIR
mkdir -p $WORKDIR
echo -e "\033[32;1mCreating workdir\033[;0m $WORKDIR"
cp -prf $src/scripts $WORKDIR/scripts
install $src/functions.sh $WORKDIR/functions
install $src/vars.sh $WORKDIR/vars
install $src/init.sh $WORKDIR/init
for i in $(ls $src/addons | sort)
do
	echo -e "\033[32;1mInstall modules:\033[;0m $i"
	. $src/addons/$i 
done
echo -e "\033[32;1mInstall busybox:\033[;0m $(which busybox)"
install $(which busybox) $WORKDIR/busybox >/dev/null
cd $WORKDIR
echo -en "\033[32;1mBuild:\033[;0m $OUTPUT "
find . | cpio -R root:root -H newc -o | gzip > $OUTPUT
echo -e "\033[32;1mDone\033[;0m"
