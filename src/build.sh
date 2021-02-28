#!/bin/bash
set -e
[ -f /etc/initrd.conf ] && . /etc/initrd.conf
. /lib/initrd/build-functions.sh
parse_args $*
. /lib/initrd/common.sh
generate_workdir
modules_install
generate_cpio
clean_directory
