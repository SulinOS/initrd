if [ -t 0 ] && [ "$nocolor" != "true" ] ;then
    C_BLACK='\e[1;30m'
    C_RED='\e[1;31m'
    C_GREEN='\e[1;32m'
    C_YELLOW='\e[1;33m'
    C_BLUE='\e[1;34m'
    C_PURPLE='\e[1;35m'
    C_CYAN='\e[1;36m'
    C_WHITE='\e[1;37m'
    C_CLEAR='\e[m'
fi
if [ "$LANG" == "" ] ; then
	if [ -f /proc/cmdline ] ; then
		LANG=$(cat /proc/cmdline | sed "s/ /\n/g" | grep LANG | sed "s/^LANG=//g")
		[ "$LANG" == "" ] && LANG="en_US.UTF-8"
	else
		LANG="en_US.UTF-8"
	fi
fi
[ "${CPIO_COMPRESS}" == "" ] && CPIO_COMPRESS=cat
LANGFILE=${LANGDIR}/$(echo $LANG).txt
msg() {
    message=$(translate $1)
    echo -e " ${C_GREEN}*${C_CLEAR} $message $2"
}

inf() {
    message=$(translate $1)
    echo -e " ${C_CYAN}*${C_CLEAR} $message $2"
}
debug() {
    message=$(translate $1)
    [ "$debug" != "true" ] || echo -e " ${C_BLUE}*${C_CLEAR} $message $2"
}
warn() {
    message=$(translate $1)
    echo -e " ${C_YELLOW}*${C_CLEAR} $message $2"
}
err() {
    message=$(translate $1)
    echo -e " ${C_RED}*${C_CLEAR} $message $2"
}
translate(){
    if [ ! -f ${LANGFILE} ] ; then
        echo $* 
        return 0
    fi
    word=$(cat ${LANGFILE} | grep "$*::" | head -n 1 | sed "s/^.*:://g")
    if [ "$word" == "" ] ; then
        echo -n "$*"
    else
        echo -n "$word"
    fi
}
