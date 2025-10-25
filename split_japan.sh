#!/bin/bash

# 設定
# 入力となる日本全体のPBFファイル
INPUT_PBF="japan-latest.osm.pbf"
# .polyファイルが格納されているディレクトリ
POLY_DIR="poly_files"
# 分割後のPBFファイルを保存するディレクトリ
OUTPUT_DIR="output_pbf"

# 出力ディレクトリがなければ作成
mkdir -p "$OUTPUT_DIR"
echo "出力先フォルダ: ${OUTPUT_DIR}"

# poly_filesフォルダ内のすべての.polyファイルに対してループ処理
for poly_file in "$POLY_DIR"/*.poly; do
    # ファイル名から拡張子 (.poly) を除去してベース名を取得 (例: 01_北海道)
    base_name=$(basename "$poly_file" .poly)
    # 出力ファイル名を定義 (例: output_pbf/01_北海道.osm.pbf)
    output_pbf="$OUTPUT_DIR/${base_name}.osm.pbf"

    echo "-----------------------------------------------------"
    echo "処理中: ${base_name} ..."
    # osmium extractコマンドを実行
    osmium extract -p "$poly_file" "$INPUT_PBF" -o "$output_pbf" --overwrite
done

echo "-----------------------------------------------------"
echo "✅ 全ての都道府県の分割が完了しました。"
