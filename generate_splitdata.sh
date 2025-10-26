#!/bin/bash
# Prevent filename encoding issues by setting UTF-8 locale
export LANG=en_US.UTF-8
# Exit immediately if a command fails
set -e

# Configuration
INPUT_DIR="output_pbf"
OUTPUT_DIR="output_mbtiles"
CONFIG_FILE="config-high.json"
PROCESS_FILE="process.lua"
DOCKER_IMAGE="tilemaker"

mkdir -p "$OUTPUT_DIR"
echo "Output directory: ${OUTPUT_DIR}"

# Process all .osm.pbf files in the input directory
for pbf_file in "$INPUT_DIR"/*.osm.pbf; do
    # Get base name (e.g., 10_Gunma)
    base_name=$(basename "$pbf_file" .osm.pbf)
    # Extract numeric prefix (e.g., 10)
    numeric_prefix=$(echo "$base_name" | cut -d'_' -f1)

    echo "-----------------------------------------------------"
    echo "Generating tiles: ${numeric_prefix} (source: ${base_name}.osm.pbf)..."
    
    # Output with numeric prefix only (e.g., output_mbtiles/10.mbtiles)
    output_mbtiles="$OUTPUT_DIR/${numeric_prefix}.mbtiles"
    
    docker run \
        -e LANG=C.UTF-8 \
        -v "$(pwd)":/data "$DOCKER_IMAGE" \
        --input "/data/${pbf_file}" \
        --output "/data/${output_mbtiles}" \
        --config "/data/${CONFIG_FILE}" \
        --process "/data/${PROCESS_FILE}" \
        --merge \
        --threads=1
    
    # Rename to full name (e.g., 10_Gunma.mbtiles)
    output_renamed="$OUTPUT_DIR/${base_name}.mbtiles"
    mv "$output_mbtiles" "$output_renamed"
    echo "Renamed to: ${output_renamed}"
done

echo "-----------------------------------------------------"
echo "Completed: Generated high-detail tiles for all prefectures."
