# Japan Offline Map Tile Generator

This is a personal project to create a self-hosted map tile pipeline for Japan. 

It generates two types of vector tiles from OpenStreetMap data:
1.  A single, low-resolution `.mbtiles` file for all of Japan (for app bundling).
2.  High-resolution, per-prefecture `.mbtiles` files (to be served by an API).

## Prerequisites

1.  **Docker:** Must be installed and running.
2.  **`osmium-tool`**: Must be installed locally for the `split_japan.sh` script.
3.  **Python 3:** Must be installed with the `geopandas` library.
    ```bash
    pip install geopandas
    ```
4.  **OSM Data:** Download `japan-latest.osm.pbf` from [Geofabrik](http://download.geofabrik.de/asia/japan.html) and place it in this directory.
5.  **GeoJSON Data:** A `japan.geojson` file containing prefecture boundaries is required (used by `app.py`).

## Workflow

Run the scripts in the following order:

### 1. Generate Polygon Files
This script (`app.py`) reads `japan.geojson` and generates the necessary boundary files (`.poly`) in the `poly_files/` directory.

```bash
python app.py
```

### 2. Split PBF by Prefecture
This script (split_japan.sh) uses osmium-tool and the poly_files/ to split japan-latest.osm.pbf into per-prefecture PBFs (e.g., 10_群馬県.osm.pbf). The results are saved in output_pbf/.

```bash
./split_japan.sh
```

### 3. Generate Low-Detail Base Map
This is a manual Docker command to create the single, app-bundle-friendly base map (e.g., japan-low.mbtiles).

```bash
sudo docker run -e LANG=C.UTF-8 -v "$(pwd)":/data tilemaker \
  --input /data/japan-latest.osm.pbf \
  --output /data/tiles/japan-low.mbtiles \
  --config /data/config-low.json \
  --process /data/process-low.lua \
  --threads=1
```

### 4. Generate High-Detail Prefecture Maps
This script (generate_splitdata.sh) loops through all PBFs in output_pbf/ and generates the high-detail tiles. The results are saved in output_mbtiles/ with numeric filenames (e.g., 1.mbtiles, 10.mbtiles).

```bash
./generate_splitdata.sh
```


