#!/bin/sh

P="achievement_icon_pal.png"
PB="achievement_icon_pal_big.png"
rm achievement_icon_pal.png
~/bin/lowtexpal -f achievement_icon_pal.png add-gradient --start-color "#523522" --end-color "#f4a039" --steps 8
~/bin/lowtexpal -f achievement_icon_pal.png add-gradient --start-color "#3d3c3c" --end-color "#b4b4b4" --steps 8
~/bin/lowtexpal -f achievement_icon_pal.png add-gradient --start-color "#8d5f3b" --end-color "#f7eb68" --steps 8
~/bin/lowtexpal -f achievement_icon_pal.png add-gradient --start-color "#2d7692" --end-color "#3bfcfc" --steps 8
~/bin/lowtexpal -f achievement_icon_pal.png add-gradient --start-color "#681077" --end-color "#d51617" --steps 8

#~/bin/lowtexpal -f achievement_icon_pal.png add-gradient --start-color "#000000" --end-color "#ffffff" --steps 8

~/bin/lowtexpal -f achievement_icon_pal.png add-color -c "#000000"
~/bin/lowtexpal -f achievement_icon_pal.png add-color -c "#ffffff"

gm convert "${P}" -filter point -resize 3200% "${PB}"
