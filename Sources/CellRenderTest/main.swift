// CellRenderTest - セルベースレンダリングプロトタイプの動作確認
//
// 期待される挙動:
// 1. "=== Cell-based Rendering Prototype Test ==="が出力される
// 2. "1. Basic text rendering:":
//    - "Hello, World!"がシアン色で表示される
//    - "SwiftTUI"が緑色・太字で2列目から表示される
// 3. "2. Overlapping backgrounds (HStack simulation):":
//    - "AAA"（赤背景）、"BBB"（緑背景）、"CCC"（青背景）が白文字で表示される
//    - 各背景色が正しく独立して表示される
// 4. "3. Overlapping borders:":
//    - 3つの隣接するボーダーボックスが描画される
//    - "A"、"B"、"C"がそれぞれのボックス内に表示される
// 5. "4. Complex example (borders with backgrounds):":
//    - "X"（黄背景）と"Y"（マゼンタ背景）がシアン色のボーダー内に表示される
// 6. "5. ANSI escape sequence handling:":
//    - ANSIエスケープシーケンスを含むテキストが正しく処理される
// 7. "=== Test Complete ==="が出力される
//
// 注意: CellBufferの低レベルAPI（bufferWriteCell、bufferFillBackground、
//       bufferDrawBorder）の動作を直接テストします
//
// 実行方法: swift run CellRenderTest

import SwiftTUI

print("=== Cell-based Rendering Prototype Test ===\n")

// 1. 基本的なテキスト描画
print("1. Basic text rendering:")
var buffer1 = CellBuffer(width: 40, height: 5)
bufferWriteCell(row: 0, col: 0, text: "Hello, World!", foregroundColor: .cyan, into: &buffer1)
bufferWriteCell(
  row: 1, col: 2, text: "SwiftTUI", foregroundColor: .green, style: .bold, into: &buffer1)
for line in buffer1.toANSILines() {
  print(line)
}

print("\n2. Overlapping backgrounds (HStack simulation):")
var buffer2 = CellBuffer(width: 40, height: 3)
// 背景色を先に塗る
bufferFillBackground(row: 0, col: 0, width: 5, height: 1, color: .red, into: &buffer2)
bufferFillBackground(row: 0, col: 5, width: 5, height: 1, color: .green, into: &buffer2)
bufferFillBackground(row: 0, col: 10, width: 5, height: 1, color: .blue, into: &buffer2)
// テキストを上に描画
bufferWriteCell(row: 0, col: 1, text: "AAA", foregroundColor: .white, into: &buffer2)
bufferWriteCell(row: 0, col: 6, text: "BBB", foregroundColor: .white, into: &buffer2)
bufferWriteCell(row: 0, col: 11, text: "CCC", foregroundColor: .white, into: &buffer2)
for line in buffer2.toANSILines() {
  print(line)
}

print("\n3. Overlapping borders:")
var buffer3 = CellBuffer(width: 40, height: 5)
// 3つのボーダーを隣接して描画
bufferDrawBorder(row: 0, col: 0, width: 5, height: 3, into: &buffer3)
bufferWriteCell(row: 1, col: 2, text: "A", into: &buffer3)

bufferDrawBorder(row: 0, col: 4, width: 5, height: 3, into: &buffer3)
bufferWriteCell(row: 1, col: 6, text: "B", into: &buffer3)

bufferDrawBorder(row: 0, col: 8, width: 5, height: 3, into: &buffer3)
bufferWriteCell(row: 1, col: 10, text: "C", into: &buffer3)

for line in buffer3.toANSILines() {
  print(line)
}

print("\n4. Complex example (borders with backgrounds):")
var buffer4 = CellBuffer(width: 40, height: 5)
// 背景色を適用
bufferFillBackground(row: 1, col: 1, width: 3, height: 1, color: .yellow, into: &buffer4)
bufferFillBackground(row: 1, col: 5, width: 3, height: 1, color: .magenta, into: &buffer4)
// ボーダーを描画
bufferDrawBorder(row: 0, col: 0, width: 5, height: 3, color: .cyan, into: &buffer4)
bufferDrawBorder(row: 0, col: 4, width: 5, height: 3, color: .cyan, into: &buffer4)
// テキストを描画
bufferWriteCell(row: 1, col: 2, text: "X", foregroundColor: .black, style: .bold, into: &buffer4)
bufferWriteCell(row: 1, col: 6, text: "Y", foregroundColor: .white, style: .bold, into: &buffer4)

for line in buffer4.toANSILines() {
  print(line)
}

print("\n5. ANSI escape sequence handling:")
var buffer5 = CellBuffer(width: 40, height: 2)
// ANSIエスケープシーケンスを含むテキスト
let ansiText = "\u{1B}[31mRed\u{1B}[0m \u{1B}[42mGreen BG\u{1B}[0m \u{1B}[1;34mBold Blue\u{1B}[0m"
bufferWriteCell(row: 0, col: 0, text: ansiText, into: &buffer5)
for line in buffer5.toANSILines() {
  print(line)
}

print("\n=== Test Complete ===")
