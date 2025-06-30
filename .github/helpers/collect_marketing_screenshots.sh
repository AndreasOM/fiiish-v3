#!/bin/sh


BASE_FOLDER="marketing"
SOURCE_FOLDER="${HOME}/Library/Application Support/Godot/app_userdata/fiiish-v3/screenshots/"

mkdir -p ${BASE_FOLDER}

TARGET_FOLDER="${BASE_FOLDER}/iphone/6_9_inch"
mkdir -p ${TARGET_FOLDER}

# 2868 × 1320px -> iPhone 6.9"

find "${SOURCE_FOLDER}" -iname "fiiish-v3-marketing-2868x1320*.png" | while read src
do
	#echo "src: >>${src}<<"
	file=${src#"$SOURCE_FOLDER"}
	#echo "file: ${file}"
	name=$(basename ${file} .png)
	#echo "${name}"
	#dst=${TARGET_FOLDER}/${name}.webp
	dst=${TARGET_FOLDER}/${name}.png

	echo "${src} -> ${dst}"
	#gm convert "${src}" "${dst}"
	cp "${src}" "${dst}"
	optipng -o 9 "${dst}"
done




