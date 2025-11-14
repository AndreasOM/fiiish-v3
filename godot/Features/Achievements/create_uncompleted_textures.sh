#!/bin/bash

FOLDER="Textures"
# gm convert achievement_icon_single_run_distance_1.png -modulate 15,25 achievement_icon_single_run_distance_1_uncompleted.png

cd ${FOLDER}

for ai in achievement_icon_*_?.png
do
	unc=$(basename ${ai} .png)_uncompleted.png

	echo "${ai} -> ${unc}"
	gm convert "${ai}" -modulate 15,25 "${unc}"
	optipng -o 9 "${unc}"

done
