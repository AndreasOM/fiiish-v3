#!/bin/sh

set -e

GODOT="/Applications/Godot4.5.app/Contents/MacOS/Godot"
#GODOT="/Applications/Godot.app/Contents/MacOS/Godot"
BUILD_TYPE="linux-demo-classic"
#PROJECT="fiiish-v3"

${GODOT} \
	--headless \
	--export-debug \
	${BUILD_TYPE} \
	../export/godot/${BUILD_TYPE}/fiiish-classic-demo.x86_64 \
	--quit \
	godot/project.godot

if [ $? -ne 0 ]
then
	exit 1
fi

scp export/godot/linux-demo-classic/* deck@192.168.186.84:.local/share/Steam/steamapps/common/Fiiish\!\ Classic\ Demo/
scp export/godot/linux-demo-classic/fiiish-classic-demo.pck deck@192.168.186.84:.local/share/Steam/steamapps/common/Fiiish\!\ Classic\ Demo/fiiish-classic.pck
scp export/godot/linux-demo-classic/fiiish-classic-demo.x86_64 deck@192.168.186.84:.local/share/Steam/steamapps/common/Fiiish\!\ Classic\ Demo/fiiish-classic.x86_64
