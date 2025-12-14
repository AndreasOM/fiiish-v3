#!/bin/sh

# ordered pairs: number name
MAPS="2 silver 3 gold 4 diamond 5 ruby"

for pair in $MAPS; do
	if [[ $pair =~ ^[0-9]+$ ]]
	then
		num=$pair
	else
		name=$pair

		optipng -o9 4x/${name}/*.png
		cp 4x/${name}/achievement_icon_*${num}.png ../../godot/Features/Achievements/Textures
	fi
done
