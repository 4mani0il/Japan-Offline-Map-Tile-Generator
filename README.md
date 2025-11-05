# Japan Offline Map Tile Generator

This is a personal project to create a self-hosted map tile pipeline for Japan. 

It generates two types of vector tiles from OpenStreetMap data:
1.  A single, low-resolution tile file for all of Japan (for app bundling).
2.  High-resolution, per-prefecture tile files (to be served by an API).

You can generate tiles in either `.mbtiles` or `.pmtiles` format:
- **mbtiles**: Use `generate_low_mbtiles.sh` and `generate_split_mbtiles.sh`
- **pmtiles**: Use `generate_low_pmtiles.sh` and `generate_split_pmtiles.sh`

## Prerequisites

1.  **Docker:** Must be installed and running.
2.  **`osmium-tool`**: Must be installed locally for the `split_japan.sh` script.
3.  **Python 3:** Must be installed with the `geopandas` library.
    ```bash
    pip install geopandas
    ```
4.  **OSM Data:** Download `japan-latest.osm.pbf` from [Geofabrik](http://download.geofabrik.de/asia/japan.html) and place it in this directory.
5.  **GeoJSON Data:** Download `japan.geojson` from [dataofjapan/land repository](https://raw.githubusercontent.com/dataofjapan/land/master/japan.geojson) and place it in this directory. This file contains prefecture boundaries and is used by `create_polys.py`.

## Workflow

### Low-Resolution Base Map
Create a single, app-bundle-friendly base map using the helper script. The output will be written to `output/00-japan.mbtiles` or `output/00-japan.pmtiles` depending on the format you choose.

**For mbtiles:**
```bash
./generate_low_mbtiles.sh
```

**For pmtiles:**
```bash
./generate_low_pmtiles.sh
```

Requirements for this step:
- `japan-latest.osm.pbf` is present in the project root
- `config-low.json` and `process-low.lua` are available in the project root

### High-Resolution Prefecture Maps
Run the scripts in the following order:

#### 1. Generate Polygon Files
This script (`create_polys.py`) reads `japan.geojson` and generates the necessary boundary files (`.poly`) in the `poly_files/` directory.

```bash
python create_polys.py
```

**Configuration:** You can modify the overlap buffer in `create_polys.py` by changing the `BUFFER_METERS` variable (default: 1000 meters).

#### 2. Split PBF by Prefecture
This script (`split_japan.sh`) uses osmium-tool and the poly_files/ to split japan-latest.osm.pbf into per-prefecture PBFs (e.g., 10_群馬県.osm.pbf). The results are saved in `output_pbf/`.

```bash
./split_japan.sh
```

#### 3. Generate High-Detail Prefecture Maps
These scripts loop through all PBFs in `output_pbf/` and generate the high-detail tiles. The results are saved in `output/` with two-digit, zero-padded prefixes (e.g., `01_PrefectureName.mbtiles` or `01_PrefectureName.pmtiles`).

**For mbtiles:**
```bash
./generate_split_mbtiles.sh
```

**For pmtiles:**
```bash
./generate_split_pmtiles.sh
```

## License
MIT License

