#!/bin/bash
# Prevent filename encoding issues by setting UTF-8 locale
export LANG=en_US.UTF-8
# Exit immediately if a command fails
set -e

# Configuration
INPUT_PBF="japan-latest.osm.pbf"
OUTPUT_DIR="output"
OUTPUT_FILE="${OUTPUT_DIR}/00-japan.mbtiles"
CONFIG_FILE="config-low.json"
PROCESS_FILE="process-low.lua"
DOCKER_IMAGE="tilemaker"

mkdir -p "$OUTPUT_DIR"
echo "Output directory: ${OUTPUT_DIR}"

if [ ! -f "$INPUT_PBF" ]; then
    echo "Error: ${INPUT_PBF} not found in current directory." >&2
    exit 1
fi

echo "-----------------------------------------------------"
echo "Generating low-resolution tiles from ${INPUT_PBF}..."

docker run \
    -e LANG=C.UTF-8 \
    -v "$(pwd)":/data "$DOCKER_IMAGE" \
    --input "/data/${INPUT_PBF}" \
    --output "/data/${OUTPUT_FILE}" \
    --config "/data/${CONFIG_FILE}" \
    --process "/data/${PROCESS_FILE}" \
    --threads=1

echo "Generated: ${OUTPUT_FILE}"
echo "-----------------------------------------------------"
echo "Completed: Generated low-resolution tiles for Japan."


