import SwiftTUI

// セルベースレンダリングのプロトタイプテスト
print("=== Cell-based Rendering Prototype Test ===\n")

// 1. 基本的なテキスト描画
print("1. Basic text rendering:")
var buffer1 = CellBuffer(width: 40, height: 5)
bufferWriteCell(row: 0, col: 0, text: "Hello, World!", foregroundColor: .cyan, into: &buffer1)
bufferWriteCell(row: 1, col: 2, text: "SwiftTUI", foregroundColor: .green, style: .bold, into: &buffer1)
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