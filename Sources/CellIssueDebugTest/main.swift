// CellIssueDebugTest - セルレンダリングの問題を詳細にデバッグ
//
// 概要:
// HStack内での背景色レンダリング問題を低レベルでデバッグするためのテスト。
// CellFlexStack、CellBackgroundLayoutView、LegacyTextを直接使用して、
// Yogaノードの計算からCellBufferへの描画までの全プロセスを追跡する。
//
// 期待される動作:
// - HStack内の各要素が独立した背景色（赤、緑、青）を持つ
// - 各列のセル内容、前景色、背景色が正しく設定される
// - ANSI出力が適切なエスケープシーケンスを含む
//
// デバッグ内容:
// 1. CellFlexStackの描画プロセスを追跡
// 2. Yogaノードのレイアウト計算結果を確認
// 3. CellBufferの内容を列ごとに検証
// 4. 個別コンポーネント（LegacyText、CellBackgroundLayoutView）の動作をテスト
//
// 実行方法:
// swift run CellIssueDebugTest

import SwiftTUI
import Foundation
import yoga

// デバッグ：HStackの問題を再現
print("=== Cell Issue Debug ===")

// シンプルなHStackを直接作成
let hstack = CellFlexStack(.row) {
    [
        LegacyAnyView(CellBackgroundLayoutView(color: .red, child: LegacyText("A"))),
        LegacyAnyView(CellBackgroundLayoutView(color: .green, child: LegacyText("B"))),
        LegacyAnyView(CellBackgroundLayoutView(color: .blue, child: LegacyText("C")))
    ]
}

// Yogaノードを計算
let node = hstack.makeNode()
node.calculate(width: 80)

// CellBufferに描画
var cellBuffer = CellBuffer(width: 80, height: 10)
hstack.paintCells(origin: (0, 0), into: &cellBuffer)

// 結果を確認
print("\n--- Cell Contents (First 10 columns) ---")
for col in 0..<10 {
    if let cell = cellBuffer.getCell(row: 0, col: col) {
        print("Col \(col): '\(cell.character)' fg=\(String(describing: cell.foregroundColor)) bg=\(String(describing: cell.backgroundColor))")
    }
}

print("\n--- ANSI Output ---")
let lines = cellBuffer.toANSILines()
for (index, line) in lines.enumerated() where index < 3 {
    print("Line \(index): \(line)")
    print("Rendered: \(line)")
}

// LegacyTextの描画を個別にテスト
print("\n--- Individual Text Test ---")
let text = LegacyText("TEST")
let textNode = text.makeNode()
textNode.calculate(width: 80)

var textBuffer: [String] = []
text.paint(origin: (0, 0), into: &textBuffer)
print("LegacyText output: \(textBuffer)")

// CellBackgroundLayoutViewの個別テスト
print("\n--- Background View Test ---")
let bgView = CellBackgroundLayoutView(color: .red, child: LegacyText("BG"))
let bgNode = bgView.makeNode()
bgNode.calculate(width: 80)

var bgBuffer = CellBuffer(width: 80, height: 5)
bgView.paintCells(origin: (0, 0), into: &bgBuffer)

print("Background view cells:")
for col in 0..<5 {
    if let cell = bgBuffer.getCell(row: 0, col: col) {
        print("  Col \(col): '\(cell.character)' bg=\(String(describing: cell.backgroundColor))")
    }
}

exit(0)