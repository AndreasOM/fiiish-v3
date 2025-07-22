#!/bin/sh


BASE_FOLDER="marketing"
SOURCE_FOLDER="${HOME}/Library/Application Support/Godot/app_userdata/fiiish-v3/screenshots/"

mkdir -p ${BASE_FOLDER}

TARGET_FOLDER="${BASE_FOLDER}/steam-classic/screenshot-assets"
mkdir -p ${TARGET_FOLDER}

find "${SOURCE_FOLDER}" -iname "fiiish-classic-steam-1920x1080*.png" | while read src
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
	# optipng -o 9 "${dst}"
done




