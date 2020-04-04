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
msg() {
    echo -e " ${C_GREEN}*${C_CLEAR} ${@}"
}

inf() {
    echo -e " ${C_CYAN}*${C_CLEAR} ${@}"
}
debug() {
    [ ! -n "$debug"  ] || echo -e " ${C_BLUE}*${C_CLEAR} ${@}"
}
warn() {
    echo -e " ${C_YELLOW}*${C_CLEAR} ${@}"
}
err() {
    echo -e " ${C_RED}*${C_CLEAR} ${@}"
}
