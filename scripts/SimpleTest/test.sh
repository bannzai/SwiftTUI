#!/bin/bash

# SimpleTest自動テストスクリプト
# 
# 用途:
# - SimpleTestを起動して初期表示を確認
# - 5秒後に自動的にESCキーを送信して終了
# - 出力をファイルに保存
#
# 使い方:
# ./scripts/SimpleTest/test.sh
#
# 出力ファイル:
# - scripts/SimpleTest/output.txt: プログラムの出力
# - scripts/SimpleTest/screenshot.txt: 最終画面のスクリーンショット（ANSIエスケープシーケンス含む）

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_FILE="$SCRIPT_DIR/output.txt"
SCREENSHOT_FILE="$SCRIPT_DIR/screenshot.txt"

echo "SimpleTest を実行しています..."
echo "5秒後に自動的に終了します..."

# タイムアウト付きで実行し、ESCキーを送信
(
    sleep 5
    echo -e '\033'  # ESCキー
) | swift run SimpleTest 2>&1 | tee "$OUTPUT_FILE"

# 最後の30行を抽出してスクリーンショットとして保存
tail -30 "$OUTPUT_FILE" > "$SCREENSHOT_FILE"

echo ""
echo "テスト完了！"
echo "出力は以下のファイルに保存されました:"
echo "- $OUTPUT_FILE"
echo "- $SCREENSHOT_FILE"
echo ""
echo "=== 最終画面 ==="
cat "$SCREENSHOT_FILE"