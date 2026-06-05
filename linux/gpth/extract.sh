#!/bin/bash

function extract {
	zipfile="$1"
	tempdir=$(mktemp -d)
	7z e -y -o"$tempdir" "$zipfile" >/dev/null

	for f in "$tempdir"/*; do
		[ -e "$f" ] || continue
		base=$(basename "$f")
		target="$TARGET_DIR/$base"
		count=1
		while [ -e "$target" ]; do
			ext="${base##*.}"
			name="${base%.*}"
			if [ "$ext" != "$base" ]; then
				newbase="${name}_$count.$ext"
			else
				newbase="${base}_$count"
			fi
			target="$TARGET_DIR/$newbase"
			((count++))
		done
		mv "$f" "$target"
	done
	rm -rf "$tempdir"
}

function do_extract {
	# Directory containing zip files
	SRC_DIR="./src"
	# Target directory for extraction
	TARGET_DIR="./extracted"

	# prereq
	sudo apt install parallel

	mkdir -p "$TARGET_DIR"
	export -f extract
	export TARGET_DIR

	find "$SRC_DIR" -maxdepth 1 -type f -name "*.zip" | parallel --no-notice extract {}
}
