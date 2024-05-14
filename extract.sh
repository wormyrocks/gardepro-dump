#!/bin/bash

set -evx
source helpers.sh

IMG=firmware_new.img
LINK=$(cat link.txt || { echo "Please include link.txt with a firmware URL" 1>&2 ; exit 1; })
erase_size=64

[[ -e ${IMG} ]] || curl -L ${LINK} -o ${IMG}
[[ $(crc32 ${IMG}) == 2ddc6a41 ]] || { echo "Please use this with firmware that matches CRC 2ddc6a41" 1>&2 ; exit 1; }

rm -rf dumped || true
mkdir -p dumped
cd dumped

python3 ../helpers.py ../${IMG}
gzip -Nd *.gz
for file in *.jffs2; do dump_jffs ${file}; done
# patch 0x3cccc2 0x63c
