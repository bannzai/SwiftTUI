// CellTextDebugTest - CellTextのセル単位レンダリングをデバッグ
//
// Expected behavior:
// - CellTextインスタンスを作成し、異なる背景色（赤、緑、青）を適用
// - 各セルの座標、文字、前景色、背景色の情報を表示
// - CellBufferへの描画結果とANSI出力を検証
//
// Note: セルベースレンダリングシステムの低レベル動作確認用
//
// How to run: swift run CellTextDebugTest

import Foundation
import SwiftTUI

// 一時的にコメントアウト - CellTextは現在のAPIに存在しません
// TODO: 新しいAPIで書き直す必要があります

print("=== CellText Debug Test ===")
print("This test is temporarily disabled due to API changes.")
print("CellText is no longer part of the public API.")

/*
// CellTextの動作をデバッグ
print("=== CellText Debug Test ===")

// CellTextを直接作成
let text1 = CellText("A").background(.red)
let text2 = CellText("B").background(.green)
let text3 = CellText("C").background(.blue)

// それぞれのノードを作成
let node1 = text1.makeNode()
let node2 = text2.makeNode()
let node3 = text3.makeNode()

print("Node sizes:")
print("  Text1: width=\(YGNodeLayoutGetWidth(node1.rawPtr)), height=\(YGNodeLayoutGetHeight(node1.rawPtr))")
print("  Text2: width=\(YGNodeLayoutGetWidth(node2.rawPtr)), height=\(YGNodeLayoutGetHeight(node2.rawPtr))")
print("  Text3: width=\(YGNodeLayoutGetWidth(node3.rawPtr)), height=\(YGNodeLayoutGetHeight(node3.rawPtr))")

// CellBufferに個別に描画
var buffer = CellBuffer(width: 20, height: 5)

print("\nPainting cells individually:")
text1.paintCells(origin: (0, 0), into: &buffer)
text2.paintCells(origin: (1, 0), into: &buffer)
text3.paintCells(origin: (2, 0), into: &buffer)

// セルの内容を確認
print("\n--- Cell Contents ---")
for col in 0..<5 {
    if let cell = buffer.getCell(row: 0, col: col) {
        print("Col \(col): '\(cell.character)' fg=\(String(describing: cell.foregroundColor)) bg=\(String(describing: cell.backgroundColor))")
    }
}

// ANSI出力
print("\n--- ANSI Output ---")
let lines = buffer.toANSILines()
for line in lines {
    print(line)
}
*/
