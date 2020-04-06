[ -d /autorun ] || return 0
inf "Starting overlay scripts"
for i in $(ls /autorun | sort)
do
	debug "Running" "$i"
	/busybox sh /autorun/$i
done
