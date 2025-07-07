#!/bin/bash

# SwiftTUI 全テストプログラム実行スクリプト
# 
# このスクリプトは Sources/ ディレクトリ内のすべての *Test プログラムを
# 順番に実行し、タイムアウトで自動的に次のテストに移行します。

# 設定
DEFAULT_TIMEOUT=10  # デフォルトのタイムアウト秒数
LOG_FILE="scripts/all-test-results.log"
SUMMARY_FILE="scripts/all-test-summary.txt"

# 色付き出力用
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ログファイルの初期化
echo "=== SwiftTUI All Tests Run - $(date) ===" > "$LOG_FILE"
echo "=== Test Summary - $(date) ===" > "$SUMMARY_FILE"

# テスト結果カウンター
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
TIMEOUT_TESTS=0

# タイムアウト設定（テストごとに異なる秒数を設定）
declare -A TIMEOUTS=(
    ["SimpleTest"]=5
    ["SimpleVStackTest"]=5
    ["HStackTest"]=5
    ["SimpleHStackTest"]=5
    ["ESCTest"]=5
    ["TestExample"]=5
    ["QuickDebugTest"]=3
    ["QuickHStackTest"]=3
    ["QuickForEachTest"]=5
    ["ManualCellTest"]=3
    ["CellRenderTest"]=3
    ["ScrollableListTest"]=12
    ["SimpleScrollableListTest"]=12
    ["ScrollDebugTest"]=12
    ["ProgressViewTest"]=10
    ["StateTest"]=8
    ["ButtonFocusTest"]=8
    ["InteractiveFormTest"]=10
    ["ToggleTest"]=8
    ["PickerTest"]=8
    ["SliderTest"]=8
    ["AlertTest"]=8
    ["ListTest"]=8
    ["ScrollViewTest"]=10
    ["ForEachTest"]=8
    ["ArrowKeyTest"]=8
    ["KeyTestVerify"]=5
)

# テスト実行関数
run_test() {
    local test_name=$1
    local timeout=${TIMEOUTS[$test_name]:-$DEFAULT_TIMEOUT}
    
    echo -e "\n${BLUE}[$((TOTAL_TESTS + 1))] Running: ${test_name}${NC} (timeout: ${timeout}s)"
    echo -e "\n=== Running $test_name (timeout: ${timeout}s) ===" >> "$LOG_FILE"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    # テスト開始時刻
    start_time=$(date +%s)
    
    # タイムアウト付きでテストを実行
    # gtimeout がない場合は timeout を使用（macOS では brew install coreutils が必要）
    if command -v gtimeout &> /dev/null; then
        TIMEOUT_CMD="gtimeout"
    else
        TIMEOUT_CMD="timeout"
    fi
    
    # テストを実行し、出力をログファイルに記録
    if $TIMEOUT_CMD $timeout swift run "$test_name" >> "$LOG_FILE" 2>&1; then
        exit_code=$?
        end_time=$(date +%s)
        duration=$((end_time - start_time))
        
        if [ $exit_code -eq 124 ]; then
            # タイムアウト
            echo -e "${YELLOW}✗ TIMEOUT${NC} ($duration seconds)"
            echo "$test_name: TIMEOUT ($duration seconds)" >> "$SUMMARY_FILE"
            TIMEOUT_TESTS=$((TIMEOUT_TESTS + 1))
        elif [ $exit_code -eq 0 ]; then
            # 成功
            echo -e "${GREEN}✓ PASSED${NC} ($duration seconds)"
            echo "$test_name: PASSED ($duration seconds)" >> "$SUMMARY_FILE"
            PASSED_TESTS=$((PASSED_TESTS + 1))
        else
            # 失敗
            echo -e "${RED}✗ FAILED${NC} (exit code: $exit_code, $duration seconds)"
            echo "$test_name: FAILED (exit code: $exit_code, $duration seconds)" >> "$SUMMARY_FILE"
            FAILED_TESTS=$((FAILED_TESTS + 1))
        fi
    else
        # タイムアウト以外のエラー
        exit_code=$?
        if [ $exit_code -eq 124 ]; then
            echo -e "${YELLOW}✗ TIMEOUT${NC}"
            echo "$test_name: TIMEOUT" >> "$SUMMARY_FILE"
            TIMEOUT_TESTS=$((TIMEOUT_TESTS + 1))
        else
            echo -e "${RED}✗ FAILED${NC} (exit code: $exit_code)"
            echo "$test_name: FAILED (exit code: $exit_code)" >> "$SUMMARY_FILE"
            FAILED_TESTS=$((FAILED_TESTS + 1))
        fi
    fi
    
    # テスト間に少し待機
    sleep 1
}

# メイン処理
echo -e "${BLUE}=== SwiftTUI All Tests Runner ===${NC}"
echo "Searching for test programs in Sources/ directory..."

# Sources ディレクトリ内の *Test ディレクトリを検索
test_dirs=$(ls -la Sources | grep "Test$" | awk '{print $9}' | grep -v "^$")

# テストディレクトリが見つからない場合
if [ -z "$test_dirs" ]; then
    echo -e "${RED}No test directories found!${NC}"
    exit 1
fi

# テストプログラムの一覧を表示
echo -e "\nFound test programs:"
echo "$test_dirs" | while read -r dir; do
    echo "  - $dir"
done

# 実行確認
echo -e "\n${YELLOW}This will run all test programs with timeout.${NC}"
echo "Default timeout: ${DEFAULT_TIMEOUT}s (some tests have custom timeouts)"
echo -e "Continue? (y/N): \c"
read -r response

if [[ ! "$response" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

# すべてのテストを実行
echo -e "\n${BLUE}Starting all tests...${NC}\n"

echo "$test_dirs" | while read -r dir; do
    if [ -n "$dir" ]; then
        # ディレクトリ名からテストプログラム名を取得
        test_name="${dir%/}"
        run_test "$test_name"
    fi
done

# 結果サマリー
echo -e "\n${BLUE}=== Test Results Summary ===${NC}"
echo -e "Total tests: $TOTAL_TESTS"
echo -e "${GREEN}Passed: $PASSED_TESTS${NC}"
echo -e "${RED}Failed: $FAILED_TESTS${NC}"
echo -e "${YELLOW}Timeout: $TIMEOUT_TESTS${NC}"

# サマリーファイルにも記録
echo -e "\n=== Summary ===" >> "$SUMMARY_FILE"
echo "Total: $TOTAL_TESTS, Passed: $PASSED_TESTS, Failed: $FAILED_TESTS, Timeout: $TIMEOUT_TESTS" >> "$SUMMARY_FILE"

echo -e "\nDetailed results saved to: ${BLUE}$LOG_FILE${NC}"
echo -e "Summary saved to: ${BLUE}$SUMMARY_FILE${NC}"

# 終了コード（失敗またはタイムアウトがあれば1）
if [ $FAILED_TESTS -gt 0 ] || [ $TIMEOUT_TESTS -gt 0 ]; then
    exit 1
else
    exit 0
fi