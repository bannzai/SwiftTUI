// ManualCellTest - 手動でのセルレンダリング操作の動作確認
//
// 期待される挙動:
// 1. "=== Manual Cell Test ==="が出力される
// 2. CellBuffer(20x5)が作成される
// 3. 手動で3つのセルが配置される:
//    - 位置(0,0): "A"（赤背景）
//    - 位置(0,1): "B"（緑背景）
//    - 位置(0,2): "C"（青背景）
// 4. "--- Cell Contents ---"セクションで各セルの内容が出力される:
//    - 各列の文字と背景色情報
// 5. "--- ANSI Output ---"セクションでANSIエスケープシーケンスが出力される:
//    - 実際のレンダリング結果が表示される
// 6. プログラムが即座に終了する（exit(0)）
//
// 注意: CellBufferの低レベルAPI（bufferFillBackground、bufferWriteCell）を
//       直接使用してセルレンダリングの基本動作を確認します
//
// 実行方法: swift run ManualCellTest

import SwiftTUI
import yoga

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