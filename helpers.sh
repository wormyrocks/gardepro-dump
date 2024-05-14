#!/bin/bash

umount /dev/mtdblock0 || true

dump_jffs () {
	outdir=${1%.jffs2}
	# load kernel modules for jffs2 system
	sudo modprobe -r mtdram || true
	sudo modprobe -r mtdblock || true
	sudo modprobe mtdram total_size=2048 erase_size=$erase_size
	sudo modprobe mtdblock
	tdir=$(mktemp -d)
	sudo dd if=${1} of=/dev/mtdblock0 
	sudo mount -t jffs2 /dev/mtdblock0 ${tdir}
	cp -r ${tdir} ${outdir}
	sudo umount /dev/mtdblock0||true
	sudo rm -rf ${tdir}
}

