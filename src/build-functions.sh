. /lib/initrd/common.sh
help_msg(){
cat <<    EOF
Usage $(basename $0) [OPTIONS]
Targeting options list:
  OUPTUP           Target initrd file output location. 
  WORKDIR          Working directory. Created by mktemp command.
  KERNELVER        Target kernel version. Default is current kernel.
  MODDIR           Target module director. Default is current module directory.
  CONFIG           Used config file location. Default is /etc/initrd.conf
General option list:
  -d / --debug     Print debug log.
  -k / --keep      Do not remove working directory after building.
  -h / --help      Print this message.
  -n / --no-color  Disable colorized output.
  -c / --no-cpio   Do not generate initrd image.
  -f / --fallback  Generate fallback initrd image.
EOF
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
	export OUTPUT=/boot/initrd.img-$(uname -r)
	export nocolor=false
	export keepworkdir=false
	export debug=false
	for i in $*
	do
		if [ "$i" == "-h" ] || [ "$i" == "--help" ] ; then
			help_msg
			exit 0
		elif [ "$i" == "-d" ] || [ "$i" == "--debug" ]; then
			debug=true
		elif [ "$i" == "-k" ] || [ "$i" == "--keep" ] ; then
			keepworkdir=true
		elif [ "$i" == "-n" ] || [ "$i" == "--no-color" ] ; then
			export nocolor=true
		elif [ "$i" == "-c" ] || [ "$i" == "--no-cpio" ] ; then
			export nocpio=true
		elif [ "$i" == "-f" ] || [ "$i" == "--fallback" ] ; then
			fallback=true
		else
			export $i
	fi
	done
}
generate_workdir(){
	msg "Creating workdir $WORKDIR"
	rm -f $WORKDIR
	mkdir -p $WORKDIR
	cp -prf $src/scripts $WORKDIR/scripts
	for file in functions vars common init
	do
		install $src/$file.sh $WORKDIR/$file
	done
	msg "Merging with overlay"
	cp -prf $src/overlay/* $WORKDIR
}
modules_install(){
	for i in $(ls $src/addons | sort)
	do
		inf "Install modules: $i"
		. $src/addons/$i 
	done
}

generate_cpio(){
	msg "Build: $OUTPUT "
	cd $WORKDIR
	if [ "$nocpio" != "true" ] ; then
		echo -ne " ${C_GREEN}*${C_CLEAR} Generating: "
		find . | cpio -R root:root -H newc -o | gzip > $OUTPUT
	fi
	if [ "$fallback" == "true" ] ; then
		echo -ne " ${C_GREEN}*${C_CLEAR} Generating fallback: "
		find . | cpio -R root:root -H newc -o | gzip > $OUTPUT-fallback
	fi
}

clean_directory(){
	if [ "$keepworkdir" != "true" ] ; then
		rm -rf $WORKDIR
		msg "Clearing workdir."
	else
		inf "Keeping workdir: $WORKDIR"
	fi
}
