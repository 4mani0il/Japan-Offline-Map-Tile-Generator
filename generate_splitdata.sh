#!/bin/bash
# ファイル名文字化け対策: ホストOSのロケールをUTF-8に設定
export LANG=en_US.UTF-8
# エラー対策: コマンドが失敗したら即座に停止
set -e

# 設定
INPUT_DIR="output_pbf"
OUTPUT_DIR="output_mbtiles"
DOCKER_IMAGE="tilemaker"

mkdir -p "$OUTPUT_DIR"
echo "出力先: ${OUTPUT_DIR}"

# output_pbfフォルダ内のすべての.osm.pbfファイルに対してループ処理
for pbf_file in "$INPUT_DIR"/*.osm.pbf; do
    # 日本語を含むベース名 (例: 10_群馬県) を取得
    base_with_jp=$(basename "$pbf_file" .osm.pbf)
    # 数字のみのベース名 (例: 10) を取得
    base_name_numeric=$(echo "$base_with_jp" | cut -d'_' -f1)

    echo "-----------------------------------------------------"
    echo "タイル生成中: ${base_name_numeric} (元ファイル: ${base_with_jp}.osm.pbf) ..."
    
    # 出力ファイル名は「数字のみ」 (例: output_mbtiles/10.mbtiles)
    output_mbtiles_numeric="$OUTPUT_DIR/${base_name_numeric}.mbtiles"
    sudo docker run \
        -e LANG=C.UTF-8 \
        -v "$(pwd)":/data "$DOCKER_IMAGE" \
        --input "/data/${pbf_file}" \
        --output "/data/${output_mbtiles_numeric}" \
        --config "/data/config-high.json" \
        --process "/data/process.lua" \
        --merge \
        --threads=1
    
    # 生成が完了した数字のファイル (10.mbtiles) を、
    # 日本語のファイル名 (10_群馬県.mbtiles) にリネームする
    output_mbtiles_jp="$OUTPUT_DIR/${base_with_jp}.mbtiles"
    mv "$output_mbtiles_numeric" "$output_mbtiles_jp"
    echo "リネーム完了: ${output_mbtiles_jp}"
done

echo "-----------------------------------------------------"
echo "✅ 全ての都道府県の高画質タイル生成が完了しました。"
