#!/bin/bash
set -e
. /lib/initrd/build-functions.sh
parse_args $*
. /lib/initrd/common.sh
generate_workdir
modules_install
generate_cpio
clean_directory
