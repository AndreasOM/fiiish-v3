#!/bin/sh
# Slice the 4×3 achievement sheet into individual 4× icons with correct filenames.

set -eu

SHEET="achievement_icons_4x_0002.png"
COLS=4
ROWS=3
OUTDIR="slices_4x"
# SCALE_PCT=25
SCALE_PCT=100

mkdir -p "$OUTDIR"

# In row-major order (left→right, top→bottom), excluding the final palette tile.
NAMES='
achievement_icon_coins_per_time_1.png
achievement_icon_day_streak_1.png
achievement_icon_max_coins_1.png
achievement_icon_play_count_1.png
achievement_icon_single_run_coins_1.png
achievement_icon_single_run_distance_1.png
achievement_icon_skill_upgrades_1.png
achievement_icon_stream_next_1.png
achievement_icon_total_coins_1.png
achievement_icon_total_distance_1.png
'

# Get sheet dimensions and per-tile size
read W H <<EOF
$(gm identify -format "%w %h" "$SHEET")
EOF

tile_w=$(( W / COLS ))
tile_h=$(( H / ROWS ))

i=0
echo "$NAMES" | while read -r NAME; do
  [ -n "$NAME" ] || continue
  row=$(( i / COLS ))
  col=$(( i % COLS ))
  x=$(( col * tile_w ))
  y=$(( row * tile_h ))

  src="$OUTDIR/$NAME"
  dest="./$NAME"

  gm convert "$SHEET" -crop "${tile_w}x${tile_h}+${x}+${y}" +repage "$src"

  gm convert "$src" -filter point -resize "${SCALE_PCT}%" "$dest"

  i=$(( i + 1 ))
done

echo "✅ Sliced $i icons into $OUTDIR/"


