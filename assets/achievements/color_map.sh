#!/bin/sh

PREFIX="achievement_pal"
INPUT="achievement_icon_atlas_4x.png"
OUTPUT_PREFIX="achievement_icon_atlas_4x"
SRC_PAL="achievement_source_pal-bronze.png"

omt-color-mapper map --input "${INPUT}" --source-pal "${SRC_PAL}" --target-pal "${PREFIX}-bronze.png"  --output "${OUTPUT_PREFIX}-bronze.png"
omt-color-mapper map --input "${INPUT}" --source-pal "${SRC_PAL}" --target-pal "${PREFIX}-silver.png"  --output "${OUTPUT_PREFIX}-silver.png"
omt-color-mapper map --input "${INPUT}" --source-pal "${SRC_PAL}" --target-pal "${PREFIX}-gold.png"    --output "${OUTPUT_PREFIX}-gold.png"
omt-color-mapper map --input "${INPUT}" --source-pal "${SRC_PAL}" --target-pal "${PREFIX}-diamond.png" --output "${OUTPUT_PREFIX}-diamond.png"
omt-color-mapper map --input "${INPUT}" --source-pal "${SRC_PAL}" --target-pal "${PREFIX}-ruby.png"    --output "${OUTPUT_PREFIX}-ruby.png"
