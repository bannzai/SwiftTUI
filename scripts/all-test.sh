#!/bin/bash

# SwiftTUI 全テストプログラム実行スクリプト
# 
# このスクリプトは Sources/ ディレクトリ内のすべての *Test プログラムを
# 順番に実行し、タイムアウトで自動的に次のテストに移行します。

# 設定
DEFAULT_TIMEOUT=15  # デフォルトのタイムアウト秒数（ビルド時間を考慮）
BUILD_TIMEOUT=30    # ビルド用のタイムアウト
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
# ビルド時間を考慮して全体的に増やす
declare -A TIMEOUTS=(
    ["SimpleTest"]=10
    ["SimpleVStackTest"]=10
    ["HStackTest"]=10
    ["SimpleHStackTest"]=10
    ["ESCTest"]=10
    ["TestExample"]=10
    ["QuickDebugTest"]=8
    ["QuickHStackTest"]=8
    ["QuickForEachTest"]=10
    ["ManualCellTest"]=8
    ["CellRenderTest"]=10
    ["ScrollableListTest"]=20
    ["SimpleScrollableListTest"]=20
    ["ScrollDebugTest"]=20
    ["ProgressViewTest"]=15
    ["StateTest"]=15
    ["ButtonFocusTest"]=15
    ["InteractiveFormTest"]=15
    ["ToggleTest"]=15
    ["PickerTest"]=15
    ["SliderTest"]=15
    ["AlertTest"]=15
    ["ListTest"]=15
    ["ScrollViewTest"]=20
    ["ForEachTest"]=15
    ["ArrowKeyTest"]=15
    ["KeyTestVerify"]=10
)

# テスト実行関数
run_test() {
    local test_name=$1
    local timeout=${TIMEOUTS[$test_name]}
    if [ -z "$timeout" ]; then
        timeout=$DEFAULT_TIMEOUT
    fi
    
    echo -e "\n${BLUE}[$((TOTAL_TESTS + 1))] Running: ${test_name}${NC} (timeout: ${timeout}s)"
    echo -e "\n=== Running $test_name (timeout: ${timeout}s) ===" >> "$LOG_FILE"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    # テスト開始時刻
    start_time=$(date +%s)
    
    # タイムアウト付きでテストを実行
    # gtimeout がない場合は timeout を使用（macOS では brew install coreutils が必要）
    if command -v gtimeout &> /dev/null; then
        TIMEOUT_CMD="gtimeout"
    elif command -v timeout &> /dev/null; then
        TIMEOUT_CMD="timeout"
    else
        # timeoutコマンドがない場合は、バックグラウンドプロセスとsleepで代替
        echo "Warning: timeout command not found. Using fallback method." | tee -a "$LOG_FILE"
        
        # バックグラウンドでテストを実行（teeを使って画面にも表示）
        # プロセスグループを使ってパイプ全体を管理
        (
            swift run "$test_name" 2>&1 | tee -a "$LOG_FILE"
        ) &
        TEST_PID=$!
        
        # タイムアウト監視用のサブシェル
        (
            sleep $timeout
            # プロセスグループ全体を終了
            if kill -0 $TEST_PID 2>/dev/null; then
                pkill -P $TEST_PID 2>/dev/null
                kill -TERM $TEST_PID 2>/dev/null
                sleep 1
                kill -KILL $TEST_PID 2>/dev/null
            fi
        ) 2>/dev/null &
        TIMEOUT_PID=$!
        
        # テストプロセスの終了を待つ
        wait $TEST_PID 2>/dev/null
        exit_code=$?
        
        # タイムアウト監視プロセスを停止
        kill -TERM $TIMEOUT_PID 2>/dev/null
        wait $TIMEOUT_PID 2>/dev/null
        
        # タイムアウトかどうかを判定
        if [ $exit_code -eq 143 ] || [ $exit_code -eq 137 ]; then
            exit_code=124  # timeoutコマンドと同じ終了コード
        fi
        
        # 以下、既存の処理に合流
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
        
        # ここで処理を終了して重複を避ける
        sleep 1
        return
    fi
    
    # timeoutコマンドが使える場合の処理
    $TIMEOUT_CMD $timeout swift run "$test_name" 2>&1 | tee -a "$LOG_FILE"
    exit_code=${PIPESTATUS[0]}
    
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
    
    # テスト間に少し待機
    sleep 1
}

# メイン処理
echo -e "${BLUE}=== SwiftTUI All Tests Runner ===${NC}"

# timeoutコマンドの確認
echo "Checking timeout command availability..."
if command -v gtimeout &> /dev/null; then
    echo -e "${GREEN}✓ Using gtimeout (GNU coreutils)${NC}"
elif command -v timeout &> /dev/null; then
    echo -e "${GREEN}✓ Using timeout${NC}"
else
    echo -e "${YELLOW}⚠ Neither timeout nor gtimeout found. Using fallback method.${NC}"
    echo "  For better performance, install coreutils:"
    echo "  brew install coreutils"
fi

echo ""
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