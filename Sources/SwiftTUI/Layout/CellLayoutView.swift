import yoga

/// セルベースレンダリングをサポートするLayoutViewプロトコル
public protocol CellLayoutView: LayoutView {
    /// セルバッファに描画（新しいメソッド）
    func paintCells(origin: (x: Int, y: Int), into buffer: inout CellBuffer)
}

/// デフォルト実装：既存のpaintメソッドをセルバッファ用に変換
public extension CellLayoutView {
    /// 従来のString配列への描画（CellBufferから変換）
    func paint(origin: (x: Int, y: Int), into buffer: inout [String]) {
        // 一時的なCellBufferを作成
        var cellBuffer = CellBuffer(width: 200, height: 100) // 十分大きなサイズ
        
        // セルバッファに描画（原点を0,0にして描画）
        paintCells(origin: (0, 0), into: &cellBuffer)
        
        // CellBufferをString配列に変換
        let lines = cellBuffer.toANSILines()
        
        // 既存のバッファにマージ（正しい位置に描画）
        for (index, line) in lines.enumerated() {
            let row = origin.y + index
            if row >= 0 {
                // 行を確保
                while buffer.count <= row {
                    buffer.append("")
                }
                
                // ANSIエスケープシーケンスを含むテキストを正しい位置に描画
                if !line.trimmingCharacters(in: .whitespaces).isEmpty {
                    // 既存のbufferWrite関数を使用
                    bufferWrite(row: row, col: origin.x, text: line, into: &buffer)
                }
            }
        }
    }
}

/// セルベースレンダリングへの移行を容易にするアダプター
public struct CellLayoutAdapter: CellLayoutView {
    let wrapped: any LayoutView
    
    public init(_ layoutView: any LayoutView) {
        self.wrapped = layoutView
    }
    
    public func makeNode() -> YogaNode {
        wrapped.makeNode()
    }
    
    public func paintCells(origin: (x: Int, y: Int), into buffer: inout CellBuffer) {
        // 従来のLayoutViewをセルバッファに変換
        var stringBuffer: [String] = []
        wrapped.paint(origin: origin, into: &stringBuffer)
        
        // String配列からCellBufferに変換
        for (row, line) in stringBuffer.enumerated() {
            if !line.isEmpty {
                bufferWriteCell(
                    row: row,
                    col: 0,
                    text: line,
                    into: &buffer
                )
            }
        }
    }
    
    public func handle(event: KeyboardEvent) -> Bool {
        wrapped.handle(event: event)
    }
}