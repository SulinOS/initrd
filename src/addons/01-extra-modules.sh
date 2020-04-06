add_extra_module(){
    while read line
    do
        name=$(basename $line)
        debug "Install" "$name"
        mkdir -p ${WORKDIR}/$line
        rmdir ${WORKDIR}/$line
        cat $line > ${WORKDIR}/$line
    done
}
for i in $EXTRA_MODULES
do
  mkdir -p ${WORKDIR}/$MODDIR/extra
  get_module_with_dep $i | add_extra_module
done
