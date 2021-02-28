. /lib/initrd/common.sh
help_msg(){
	if [ -f /lib/initrd/locale/helpmsg/$LANG.txt ] ; then
		cat /lib/initrd/locale/helpmsg/$LANG.txt
	else
		cat /lib/initrd/locale/helpmsg/default.txt
	fi
}

get_module_with_dep(){
	name=$1
	modinfo $name | grep filename | awk '{print $2}'
	for i in $(modinfo $name | grep depends | awk '{print $2}' | sed "s/,/ /g")
	do
		modinfo $i | grep filename | awk '{print $2}'
	done
}
parse_args(){
	export src=/lib/initrd/
	export WORKDIR=$(mktemp)
	export nocolor=false
	export keepworkdir=false
	export skipglibc=false
	export skipfsck=false
	export skipudev=false
	export allmodule=false
	export minimal=true
	export LANGDIR=/lib/initrd/locale
	for i in $*
	do
		if [ "$i" == "-h" ] || [ "$i" == "--help" ] ; then
			help_msg
			exit 0
		elif [ "$i" == "-d" ] || [ "$i" == "--debug" ]; then
			debug=true
		elif [ "$i" == "-k" ] || [ "$i" == "--keep" ] ; then
			keepworkdir=true
		elif [ "$i" == "-g" ] || [ "$i" == "--no-glibc" ] ; then
			skipglibc=true
		elif [ "$i" == "-s" ] || [ "$i" == "--no-fsck" ] ; then
			skipfsck=true
		elif [ "$i" == "-u" ] || [ "$i" == "--no-udev" ] ; then
			export skipudev=true
		elif [ "$i" == "-n" ] || [ "$i" == "--no-color" ] ; then
			export nocolor=true
		elif [ "$i" == "-c" ] || [ "$i" == "--no-cpio" ] ; then
			export nocpio=true
		elif [ "$i" == "-f" ] || [ "$i" == "--fallback" ] ; then
			fallback=true
		elif [ "$i" == "-a" ] || [ "$i" == "--all-modules" ] ; then
			minimal=false
			allmodule=true
		elif [ "$i" == "-m" ] || [ "$i" == "--full-modules" ] ; then
			minimal=false
		else
			export $i 2>/dev/null || true
	fi
	done
}
generate_workdir(){
	msg "Creating workdir" "$WORKDIR"
	rm -f $WORKDIR
	mkdir -p $WORKDIR/autorun
	mkdir -p $WORKDIR/lib
	# Debian support (multiarch not supported)
	ln -s lib $WORKDIR/lib23
	ln -s lib $WORKDIR/lib64
	ln -s ../ $WORKDIR/lib/$(uname -m)-linux-gnu
	# create fake /usr directory
	mkdir -p $WORKDIR/usr
	ln -s ../lib $WORKDIR/usr/lib
	ln -s ../lib $WORKDIR/usr/lib32
	ln -s ../lib $WORKDIR/usr/lib64
	ln -s ../bin $WORKDIR/usr/bin
	ln -s ../xbin $WORKDIR/usr/xbin
	cp -prf $src/scripts $WORKDIR/scripts
	for file in functions vars common init
	do
		install $src/$file.sh $WORKDIR/$file
	done
	msg "Merging with overlay"
	cp -prf $src/overlay/* $WORKDIR
	mkdir $WORKDIR/locale
	cp -prf $src/locale/* $WORKDIR/locale
}
modules_install(){
	for i in $(ls $src/addons | sort)
	do
		inf "Install modules" "$i"
		. $src/addons/$i 
	done
}

generate_cpio(){
	msg "Building" "$OUTPUT "
	cd $WORKDIR
	if [ "$nocpio" != "true" ] ; then
		echo -ne " ${C_GREEN}*${C_CLEAR} $(translate 'Generating') "
		find . | cpio -R root:root -H newc -o | ${CPIO_COMPRESS} > $OUTPUT
	fi
	if [ "$fallback" == "true" ] ; then
		echo -ne " ${C_GREEN}*${C_CLEAR} $(translate 'Generating fallback') "
		find . | cpio -R root:root -H newc -o | ${CPIO_COMPRESS} > $OUTPUT-fallback
	fi
}

clean_directory(){
	if [ "$keepworkdir" != "true" ] ; then
		rm -rf $WORKDIR
		msg "Clearing workdir"
	else
		inf "Keeping workdir" "$WORKDIR"
	fi
}
