#!/bin/bash

# ButtonFocusTest自動テストスクリプト
# 
# 用途:
# - ButtonFocusTestを起動してボタンフォーカス機能をテスト
# - Tab、Enter、Space、qキーの動作を確認
# - カウンターとメッセージの状態変更を確認
#
# 使い方:
# ./scripts/ButtonFocusTest/test.sh
#
# 出力ファイル:
# - scripts/ButtonFocusTest/output.txt: プログラムの出力
# - scripts/ButtonFocusTest/screenshot.txt: 各操作後のスクリーンショット

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_FILE="$SCRIPT_DIR/output.txt"
SCREENSHOT_FILE="$SCRIPT_DIR/screenshot.txt"

echo "ButtonFocusTest を実行しています..."
echo "自動的にボタン操作をテストします..."

# 自動操作のシーケンス
(
    sleep 3         # 初期表示を待つ
    echo -e '\t'    # Tab: 最初のボタン(Count++)にフォーカス
    sleep 1
    echo -e '\n'    # Enter: Count++をクリック
    sleep 1
    echo -e '\t'    # Tab: 次のボタン(Count--)にフォーカス
    sleep 1
    echo -e ' '     # Space: Count--をクリック
    sleep 1
    echo -e '\t'    # Tab: 次のボタン(Toggle Message)にフォーカス
    sleep 1
    echo -e '\n'    # Enter: Toggle Messageをクリック
    sleep 1
    echo -e '\t'    # Tab: 次のボタン(Reset)にフォーカス
    sleep 1
    echo -e ' '     # Space: Resetをクリック
    sleep 1
    echo 'q'        # q: プログラムを終了
) | swift run ButtonFocusTest 2>&1 | tee "$OUTPUT_FILE"

# 最後の50行を抽出してスクリーンショットとして保存
tail -50 "$OUTPUT_FILE" > "$SCREENSHOT_FILE"

echo ""
echo "テスト完了！"
echo "出力は以下のファイルに保存されました:"
echo "- $OUTPUT_FILE"
echo "- $SCREENSHOT_FILE"