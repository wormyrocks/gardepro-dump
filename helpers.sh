#!/bin/bash

umount /dev/mtdblock0 || true

slurp_jffs () {
	echo old crc: $(crc32 ${1})
	sz=$(wc -c < ${1})
	rm ${1}
	mkfs.jffs2 --root=${1%.jffs2} --output=${1} eraseblock=${erase_size} --pad ${sz}
	echo new crc: $(crc32 ${1})
}

re_gzip() {
	orig_address=${1%.gz}
	gzip -lNv ${1} | tail -n-1 | awk '{print $2 " " $9}' | {
		read orig_crc orig_name
		echo packing 
	}
}

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

