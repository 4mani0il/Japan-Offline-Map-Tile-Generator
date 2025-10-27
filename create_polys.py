# create_polys.py
import geopandas as gpd
import os

# Configuration
GEOJSON_FILE = 'japan.geojson'
OUTPUT_DIR = 'poly_files'
BUFFER_METERS = 1000
PREF_NAME_PROPERTY = 'nam'
PREF_CODE_PROPERTY = 'id'
def create_poly_files():
    print(f"Loading GeoJSON file '{GEOJSON_FILE}'...")
    if not os.path.exists(GEOJSON_FILE):
        print(f"Error: File not found. Please provide '{GEOJSON_FILE}'.")
        return

    os.makedirs(OUTPUT_DIR, exist_ok=True)
    print(f"Output directory: '{OUTPUT_DIR}'")

    gdf = gpd.read_file(GEOJSON_FILE)
    projected_crs = 'EPSG:32654'
    geographic_crs = 'EPSG:4326'
    
    print(f"Processing {len(gdf)} prefectures...")

    for index, row in gdf.iterrows():
        pref_name = row[PREF_NAME_PROPERTY]
        # Remove administrative suffixes (Ken, Fu, To, Do)
        pref_name_clean = pref_name.replace(' Ken', '').replace(' Fu', '').replace(' To', '').replace(' Do', '')
        # Special case for Hokkaido
        if pref_name_clean == 'Hokkai':
            pref_name_clean = 'Hokkaido'
        pref_code = row[PREF_CODE_PROPERTY]
        geometry = row.geometry
        file_basename = f"{pref_code}_{pref_name_clean}"
        
        print(f"  Processing: {file_basename}...")

        geom_projected = gpd.GeoSeries([geometry], crs=geographic_crs).to_crs(projected_crs).iloc[0]
        geom_buffered = geom_projected.buffer(BUFFER_METERS)
        geom_final = gpd.GeoSeries([geom_buffered], crs=projected_crs).to_crs(geographic_crs).iloc[0]

        # Handle different polygon types
        if geom_final.geom_type == 'Polygon':
            polygons = [geom_final]
        elif geom_final.geom_type == 'MultiPolygon':
            polygons = list(geom_final.geoms)
        else:
            polygons = []

        # Filter valid polygons (with at least 4 vertices)
        valid_parts = []
        for p in polygons:
            if len(p.exterior.coords) >= 4:
                valid_parts.append(p)
        
        if not valid_parts:
            print(f"  Warning: {file_basename} - no valid polygons found, skipping.")
            continue

        # Generate .poly file content
        poly_content = f"{file_basename}\n"
        part_counter = 1
        for poly in valid_parts:
            poly_content += f"{part_counter}\n"
            coords = poly.exterior.coords
            for x, y in coords:
                poly_content += f"    {x:.6f}    {y:.6f}\n"
            poly_content += "END\n"
            part_counter += 1
        poly_content += "END\n"

        output_filename = os.path.join(OUTPUT_DIR, f"{file_basename}.poly")
        with open(output_filename, 'w', encoding='utf-8') as f:
            f.write(poly_content)

    print(f"\nCompleted: generated {len(gdf)} .poly files in '{OUTPUT_DIR}'.")


if __name__ == '__main__':
    create_poly_files()
