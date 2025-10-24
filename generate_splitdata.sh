#!/bin/bash
# 2. (エラー対策) コマンドが失敗したら即座に停止
set -e

# --- 設定 ---
INPUT_DIR="output_pbf"
OUTPUT_DIR="output_mbtiles"
DOCKER_IMAGE="tilemaker"
# ---

mkdir -p "$OUTPUT_DIR"
echo "出力先: ${OUTPUT_DIR}"

# output_pbfフォルダ内のすべての.osm.pbfファイルに対してループ処理
for pbf_file in "$INPUT_DIR"/*.osm.pbf; do
  
  # ▼▼▼ 修正点 ▼▼▼
  # ファイル名 (例: 10_群馬県.osm.pbf) から、
  # 1. 拡張子を除去 (10_群馬県)
  base_with_jp=$(basename "$pbf_file" .osm.pbf)
  # 2. '_' で分割し、最初の部分（数字）だけを取得 (10)
  base_name=$(echo "$base_with_jp" | cut -d'_' -f1)
  # ▲▲▲ 修正ここまで ▲▲▲

  echo "-----------------------------------------------------"
  echo "タイル生成中: ${base_name} (元ファイル: ${base_with_jp}.osm.pbf) ..."
  
  # 出力ファイル名を数字だけにする (例: output_mbtiles/10.mbtiles)
  output_mbtiles="$OUTPUT_DIR/${base_name}.mbtiles"
  
  sudo docker run \
    -e LANG=C.UTF-8 \
    -v "$(pwd)":/data "$DOCKER_IMAGE" \
    --input "/data/${pbf_file}" \
    --output "/data/${output_mbtiles}" \
    --config "/data/config-high.json" \
    --process "/data/process.lua" \
    --merge \
    --threads=1
    
done

echo "-----------------------------------------------------"
echo "✅ 全ての都道府県の高画質タイル生成が完了しました。"
