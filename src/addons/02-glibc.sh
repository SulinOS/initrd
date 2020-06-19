if [ "$skipglibc" != "false" ] ; then
	warn "glibc will not install"
	return 0
fi
mkdir -p ${WORKDIR}/lib 2>/dev/null || true
mkdir -p ${WORKDIR}/xbin 2>/dev/null || true
msg "Install" "glibc"
for i in libdl.so.2 libc.so.6 ld-linux-x86-64.so.2
do
	[ -f /lib/$i ] && LIBDIR=/lib
        [ -f /lib/x86_64-linux-gnu/$i ] && LIBDIR=/lib/x86_64-linux-gnu
	[ -f /lib64/$i ] && LIBDIR=/lib64
	[ -f /usr/lib/$i ] && LIBDIR=/usr/lib
	[ -f /usr/lib64/$i ] && LIBDIR=/usr/lib64
	install ${LIBDIR}/$i ${WORKDIR}/lib/$i || true
done
mkdir ${WORKDIR}/xbin 2>/dev/null || true
copy_binary(){
	for bins in $*
	do
		if [ "" != "$(which $bins)" ] ; then
			libs="$(ldd $(which $bins) | grep '=>' | awk '{print $3}')"
			for i in $libs
			do
				lib=$(basename $i)
				install $i ${WORKDIR}/lib/$lib || true
			done
			msg "Install" "$(which $bins)"
			install $(which $bins) ${WORKDIR}/xbin/$bins
		else
			inf "Not found" "$bins"
		fi
	done
}
