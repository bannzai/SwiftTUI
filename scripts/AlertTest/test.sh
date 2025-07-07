#!/bin/bash

# AlertTest自動テストスクリプト
# 
# 用途:
# - AlertTestを起動してアラート機能をテスト
# - Tabキーでフォーカス移動、Enterでボタンクリック、ESCでアラート閉じる操作を自動化
# - 最終的にESCキーでプログラムを終了
#
# 使い方:
# ./scripts/AlertTest/test.sh
#
# 出力ファイル:
# - scripts/AlertTest/output.txt: プログラムの出力
# - scripts/AlertTest/screenshot.txt: 各操作後のスクリーンショット

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_FILE="$SCRIPT_DIR/output.txt"
SCREENSHOT_FILE="$SCRIPT_DIR/screenshot.txt"

echo "AlertTest を実行しています..."
echo "自動的にボタンをクリックしてアラートを表示します..."

# 自動操作のシーケンス
(
    sleep 3     # 初期表示を待つ
    echo -e '\t'    # Tab: 最初のボタンにフォーカス
    sleep 1
    echo -e '\n'    # Enter: ボタンをクリック（アラート表示）
    sleep 2
    echo -e '\033'  # ESC: アラートを閉じる
    sleep 1
    echo -e '\t'    # Tab: 次のボタンにフォーカス
    sleep 1
    echo -e ' '     # Space: ボタンをクリック（アラート表示）
    sleep 2
    echo -e '\n'    # Enter: アラートを閉じる
    sleep 1
    echo -e '\033'  # ESC: プログラムを終了
) | swift run AlertTest 2>&1 | tee "$OUTPUT_FILE"

# 最後の50行を抽出してスクリーンショットとして保存
tail -50 "$OUTPUT_FILE" > "$SCREENSHOT_FILE"

echo ""
echo "テスト完了！"
echo "出力は以下のファイルに保存されました:"
echo "- $OUTPUT_FILE"
echo "- $SCREENSHOT_FILE"