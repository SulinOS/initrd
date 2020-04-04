get_module_with_dep(){
    name=$1
    modinfo $name | grep filename | awk '{print $2}'
    for i in $(modinfo $name | grep depends | awk '{print $2}' | sed "s/,/ /g")
    do
        modinfo $i | grep filename | awk '{print $2}'
    done
}
add_extra_module(){
    while read line
    do
        name=$(basename $line)
        echo -e "  \033[34;1mInstall:\033[;0m $name"
        cat $line > ${WORKDIR}/$MODDIR/extra/$name
    done
}
for i in $EXTRA_MODULES
do
  mkdir -p ${WORKDIR}/$MODDIR/extra
  get_module_with_dep $i | add_extra_module
done
