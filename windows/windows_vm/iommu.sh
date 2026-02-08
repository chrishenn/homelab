#!/bin/bash

#for d in /sys/kernel/iommu_groups/*/devices/*; do
#    n=${d#*/iommu_groups/*}
#    n=${n%%/*}
#    if lspci -nns "${d##*/}" | grep -qi vga; then
#        printf 'IOMMU Group: %s ' "$n"
#        lspci -nns "${d##*/}"
#    fi
#done

shopt -s nullglob
for g in $(find /sys/kernel/iommu_groups/* -maxdepth 0 -type d | sort -V); do
	echo "IOMMU Group ${g##*/}:"
	for d in "$g/devices"/*; do
		echo -e "\t$(lspci -D -nns "${d##*/}")"
	done
done
