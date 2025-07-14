import Testing
@testable import SwiftTUI
import yoga

/// テスト用のレンダラー
/// ViewをレンダリングしてANSIエスケープシーケンスを除去した純粋なテキストを返す
class TestRenderer {
    /// Viewをレンダリングして純粋なテキストを返す
    static func render<V: View>(_ view: V, width: Int = 80, height: Int = 24) -> String {
        // ViewをLayoutViewに変換
        let layoutView = ViewRenderer.renderView(view)
        
        // CellBufferを使用してレンダリング
        var cellBuffer = CellBuffer(width: width, height: height)
        
        // Yogaレイアウト計算
        let node = layoutView.makeNode()
        node.calculate(width: Float(width))
        
        // セルベースレンダリング
        if let cellLayoutView = layoutView as? CellLayoutView {
            cellLayoutView.paintCells(origin: (0, 0), into: &cellBuffer)
        } else {
            // 従来のLayoutViewをアダプター経由で描画
            let adapter = CellLayoutAdapter(layoutView)
            adapter.paintCells(origin: (0, 0), into: &cellBuffer)
        }
        
        // CellBufferをANSIラインに変換
        let lines = cellBuffer.toANSILines()
        
        // ANSIエスケープシーケンスを除去して結合
        return lines.map { stripANSI($0) }.joined(separator: "\n")
    }
    
    /// ANSIエスケープシーケンスを除去
    private static func stripANSI(_ text: String) -> String {
        // ANSIエスケープシーケンスのパターン
        // ESC[...m形式のシーケンスを除去
        let pattern = "\u{1B}\\[[0-9;]*m"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: text.utf16.count)
        return regex.stringByReplacingMatches(in: text, options: [], range: range, withTemplate: "")
    }
}

// MARK: - Swift Testing Support

/// レンダリング結果から空白行を除去して比較しやすくする（Swift Testing用）
func normalizeOutput(_ output: String) -> String {
    let lines = output.components(separatedBy: "\n")
    // 空白行を除去し、各行の末尾の空白を削除
    let nonEmptyLines = lines
        .map { $0.trimmingCharacters(in: .whitespaces) }
        .filter { !$0.isEmpty }
    return nonEmptyLines.joined(separator: "\n")
}

/// 期待値と実際の出力を比較（Swift Testing用）
func expectRenderedOutput<V: View>(_ view: V, equals expected: String, 
                                   sourceLocation: SourceLocation = #_sourceLocation) {
    let output = TestRenderer.render(view)
    let normalizedOutput = normalizeOutput(output)
    let normalizedExpected = normalizeOutput(expected)
    
    #expect(normalizedOutput == normalizedExpected, 
           "Rendered output does not match expected",
           sourceLocation: sourceLocation)
}