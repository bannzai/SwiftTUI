import SwiftTUI

// デバッグ用のシンプルなテスト
struct SimpleCellDebugTest {
    static func run() {
        print("=== Cell Buffer Debug Test ===")
        
        var buffer = CellBuffer(width: 10, height: 5)
        
        // HStackのように3つの要素を並べてテスト
        // 1つ目：赤背景のA
        bufferWriteCell(row: 0, col: 0, text: "A", backgroundColor: .red, into: &buffer)
        
        // 2つ目：緑背景のB
        bufferWriteCell(row: 0, col: 1, text: "B", backgroundColor: .green, into: &buffer)
        
        // 3つ目：青背景のC
        bufferWriteCell(row: 0, col: 2, text: "C", backgroundColor: .blue, into: &buffer)
        
        // セルの内容を確認
        print("\n--- Cell Contents ---")
        for col in 0..<3 {
            if let cell = buffer.getCell(row: 0, col: col) {
                print("Col \(col): char='\(cell.character)' bg=\(String(describing: cell.backgroundColor))")
            }
        }
        
        // ANSI変換結果を確認
        print("\n--- ANSI Output ---")
        let lines = buffer.toANSILines()
        for (index, line) in lines.enumerated() {
            print("Line \(index): \(line)")
            // 実際の出力も表示
            print("Rendered: \(line)")
        }
        
        // 各セルのtoANSI()を個別に確認
        print("\n--- Individual Cell ANSI ---")
        for col in 0..<3 {
            if let cell = buffer.getCell(row: 0, col: col) {
                let ansi = cell.toANSI()
                print("Col \(col) ANSI: \(ansi.debugDescription)")
                print("Col \(col) Rendered: \(ansi)")
            }
        }
    }
}

SimpleCellDebugTest.run()