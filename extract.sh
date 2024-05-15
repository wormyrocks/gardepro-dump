#!/bin/bash

set -evx
source helpers.sh
IMG=firmware_new.img
LINK=$(cat link.txt || { echo "Please include link.txt with a firmware URL" 1>&2 ; exit 1; })
erase_size=64

unpack() {
	[[ -e ${IMG} ]] || curl -L ${LINK} -o ${IMG}
	OUTDIR=$(crc32 ${IMG})
	#[[ $(crc32 ${IMG}) == 2ddc6a41 ]] || { echo "Please use this with firmware that matches CRC 2ddc6a41" 1>&2 ; exit 1; }

	rm -rf ${OUTDIR} || true
	mkdir -p ${OUTDIR}
	cd ${OUTDIR}

	python3 ../helpers.py unpack ../${IMG} ../locations.csv
	gzip -kNd *.gz
	for file in *.jffs2; do dump_jffs ${file}; done
}
pack() {
	[[ -e ${IMG} ]] && {
		OUTDIR=$(crc32 ${IMG})
		[[ -e ${OUTDIR} ]] || false && {
			cd ${OUTDIR}
			for file in *.jffs2; do slurp_jffs ${file}; done
			for file in *.gz; do re_gzip ${file}; done
			python3 ../helpers.py pack ../${IMG}.repack ../locations.csv
		}
	} || echo Run \'./extract.sh unpack\' first. 
}

[[ -z ${1} ]] || echo Usage: ./extract.sh [unpack\|pack] && ${1}
