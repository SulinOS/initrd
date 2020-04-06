if [ "$skipglibc" != "false" ] ; then
	warn "glibc will not install"
	return 0
fi
mkdir -p ${WORKDIR}/lib 2>/dev/null || true
mkdir -p ${WORKDIR}/xbin 2>/dev/null || true
msg "Install" "glibc"
for i in #libtinfo.so.5 libdl.so.2 libc.so.6 ld-linux-x86-64.so.2
do
	[ -f /lib/$i ] && LIBDIR=/lib
	[ -f /lib64/$i ] && LIBDIR=/lib64
	[ -f /usr/lib/$i ] && LIBDIR=/usr/lib
	[ -f /usr/lib64/$i ] && LIBDIR=/usr/lib64
	install ${LIBDIR}/$i ${WORKDIR}/lib/$i || true
done
copy_binary(){
	for bins in $*
	do
		libs="$(ldd $(which $bins) | grep '=>' | awk '{print $1}')"
		for i in $libs
		do
			lib=$(basename $i)
			if [ ! -f "${WORKDIR}/$lib" ] ; then
				debug "Install" "$lib"
				[ -f /lib/$lib ] && LIBDIR=/lib
				[ -f /lib64/$lib ] && LIBDIR=/lib64
				[ -f /usr/lib/$lib ] && LIBDIR=/usr/lib
				[ -f /usr/lib64/$lib ] && LIBDIR=/usr/lib64
				install ${LIBDIR}/$lib ${WORKDIR}/lib/$lib || true
			fi
		done
		msg "Install" "$(which $bins)"
		install $(which $bins) ${WORKDIR}/xbin/$bins
	done
}
