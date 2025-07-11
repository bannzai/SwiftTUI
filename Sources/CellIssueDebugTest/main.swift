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

// 一時的にコメントアウト - 内部APIは現在のバージョンに存在しません
// TODO: 新しいAPIで書き直す必要があります

print("=== Cell Issue Debug ===")
print("This test is temporarily disabled due to API changes.")
print("CellFlexStack, CellBackgroundLayoutView are no longer part of the public API.")

/*
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

// ノードとレイアウト計算
let node = hstack.makeNode()
node.calculate(width: 20)

print("=== Layout Calculation ===")
print("HStack width: \(node.width), height: \(node.height)")

// CellBufferに描画
var buffer = CellBuffer(width: 20, height: 5)

print("\n=== Painting to CellBuffer ===")
hstack.paintCells(origin: (0, 0), into: &buffer)

// セルの内容を確認
print("\n=== Cell Contents ===")
for row in 0..<Int(node.height) {
    for col in 0..<Int(node.width) {
        if let cell = buffer.getCell(row: row, col: col) {
            print("[\(row),\(col)]: '\(cell.character)' fg=\(String(describing: cell.foregroundColor)) bg=\(String(describing: cell.backgroundColor))")
        }
    }
}

// ANSI出力
print("\n=== ANSI Output ===")
let lines = buffer.toANSILines()
for line in lines {
    print(line)
}

// デバッグ：個別コンポーネントをテスト
print("\n\n=== Testing Individual Components ===")

// LegacyTextのみ
let text = LegacyText("X")
let textNode = text.makeNode()
textNode.calculate(width: 10)
print("LegacyText size: \(textNode.width)x\(textNode.height)")

// CellBackgroundLayoutViewのみ
let bgView = CellBackgroundLayoutView(color: .cyan, child: LegacyText("Y"))
let bgNode = bgView.makeNode()
bgNode.calculate(width: 10)
print("CellBackgroundLayoutView size: \(bgNode.width)x\(bgNode.height)")
*/