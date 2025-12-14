#!/bin/bash
set -euo pipefail

mkdir -p 4x/bronze
mkdir -p 4x/silver
mkdir -p 4x/gold
mkdir -p 4x/diamond
mkdir -p 4x/ruby

~/bin/omt-atlas uncombine --input achievement_icon_atlas_4x-bronze --output-path 4x/bronze --force



SRC_DIR="4x/bronze"
SRC_PAL="achievement_pal-bronze.png"

# ordered pairs: number name
MAPS="2 silver 3 gold 4 diamond 5 ruby"

for pair in $MAPS; do
  if [[ $pair =~ ^[0-9]+$ ]]
  then
    num=$pair
  else
    name=$pair
    TGT_DIR="4x/${name}"
    TGT_PAL="achievement_pal-${name}.png"
    mkdir -p "$TGT_DIR"

    echo "→ Mapping bronze → ${name}"
    for f in "${SRC_DIR}"/*_1.png; do
      base="$(basename "$f")"
      out="${base/_1.png/_${num}.png}"
      omt-color-mapper map \
        --source-pal "$SRC_PAL" \
        --target-pal "$TGT_PAL" \
        --input "$f" \
        --output "${TGT_DIR}/${out}"
    done
  fi
done
