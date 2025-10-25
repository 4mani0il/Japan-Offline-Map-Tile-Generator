# create_polys.py
import geopandas as gpd
import os

# 設定項目
GEOJSON_FILE = 'japan.geojson'
OUTPUT_DIR = 'poly_files'
BUFFER_METERS = 1000
PREF_NAME_PROPERTY = 'nam_ja'
PREF_CODE_PROPERTY = 'id'
def create_poly_files():
    print(f"🌍 GeoJSONファイル '{GEOJSON_FILE}' を読み込みます...")
    if not os.path.exists(GEOJSON_FILE):
        print(f"エラー: ファイルが見つかりません。'{GEOJSON_FILE}' を用意してください。")
        return

    os.makedirs(OUTPUT_DIR, exist_ok=True)
    print(f"📂 出力先フォルダ: '{OUTPUT_DIR}'")

    gdf = gpd.read_file(GEOJSON_FILE)
    projected_crs = 'EPSG:32654'
    geographic_crs = 'EPSG:4326'
    
    print(f"⚙️  {len(gdf)} 件の都道府県データを処理します...")

    for index, row in gdf.iterrows():
        pref_name = row[PREF_NAME_PROPERTY]
        pref_code = row[PREF_CODE_PROPERTY]
        geometry = row.geometry
        file_basename = f"{pref_code}_{pref_name}"
        
        print(f"  -> {file_basename} を処理中...")

        geom_projected = gpd.GeoSeries([geometry], crs=geographic_crs).to_crs(projected_crs).iloc[0]
        geom_buffered = geom_projected.buffer(BUFFER_METERS)
        geom_final = gpd.GeoSeries([geom_buffered], crs=projected_crs).to_crs(geographic_crs).iloc[0]

        # ポリゴンタイプに応じて処理
        if geom_final.geom_type == 'Polygon':
            polygons = [geom_final]
        elif geom_final.geom_type == 'MultiPolygon':
            polygons = list(geom_final.geoms)
        else:
            polygons = []

        # 有効なポリゴン（頂点が4つ以上）だけをフィルタリング
        valid_parts = []
        for p in polygons:
            if len(p.exterior.coords) >= 4:
                valid_parts.append(p)
        
        if not valid_parts:
            print(f"  -> 警告: {file_basename} に有効なポリゴン部分が見つかりませんでした。スキップします。")
            continue

        # .polyファイルの中身を生成
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

    print(f"\n✅ 処理が完了しました。'{OUTPUT_DIR}' フォルダに {len(gdf)}個の.polyファイルを生成しました。")


if __name__ == '__main__':
    create_poly_files()
