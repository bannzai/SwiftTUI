import SwiftTUI
import yoga

// 手動でセルレンダリングをテスト
print("=== Manual Cell Test ===")

// CellBufferを作成
var buffer = CellBuffer(width: 20, height: 5)

// 手動で3つのテキストを配置
// A (赤背景)
bufferFillBackground(row: 0, col: 0, width: 1, height: 1, color: .red, into: &buffer)
bufferWriteCell(row: 0, col: 0, text: "A", into: &buffer)

// B (緑背景)
bufferFillBackground(row: 0, col: 1, width: 1, height: 1, color: .green, into: &buffer)
bufferWriteCell(row: 0, col: 1, text: "B", into: &buffer)

// C (青背景)
bufferFillBackground(row: 0, col: 2, width: 1, height: 1, color: .blue, into: &buffer)
bufferWriteCell(row: 0, col: 2, text: "C", into: &buffer)

// 結果を出力
print("\n--- Cell Contents ---")
for col in 0..<5 {
    if let cell = buffer.getCell(row: 0, col: col) {
        print("Col \(col): '\(cell.character)' bg=\(String(describing: cell.backgroundColor))")
    }
}

print("\n--- ANSI Output ---")
let lines = buffer.toANSILines()
for (index, line) in lines.enumerated() {
    print("Line \(index): \(line)")
    print("Rendered: \(line)")
}


exit(0)