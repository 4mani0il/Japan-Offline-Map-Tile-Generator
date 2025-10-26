#!/bin/bash

# Configuration
INPUT_PBF="japan-latest.osm.pbf"
POLY_DIR="poly_files"
OUTPUT_DIR="output_pbf"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"
echo "Output directory: ${OUTPUT_DIR}"

# Process all .poly files in the directory
for poly_file in "$POLY_DIR"/*.poly; do
    # Get base name by removing .poly extension (e.g., 01_Hokkaido)
    base_name=$(basename "$poly_file" .poly)
    # Define output filename (e.g., output_pbf/01_Hokkaido.osm.pbf)
    output_pbf="$OUTPUT_DIR/${base_name}.osm.pbf"

    echo "-----------------------------------------------------"
    echo "Processing: ${base_name}..."
    # Run osmium extract command
    osmium extract -p "$poly_file" "$INPUT_PBF" -o "$output_pbf" --overwrite
done

echo "-----------------------------------------------------"
echo "Completed: Split all prefectures into separate files."
