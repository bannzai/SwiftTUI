import yoga

/// 背景色を適用するLayoutView
internal struct BackgroundLayoutView: LayoutView {
    let color: Color
    let child: any LayoutView
    
    init(color: Color, child: any LayoutView) {
        self.color = color
        self.child = child
    }
    
    func makeNode() -> YogaNode {
        // 子ノードのサイズをそのまま使用
        return child.makeNode()
    }
    
    func paint(origin: (x: Int, y: Int), into buffer: inout [String]) {
        // まず子ビューを描画して、その範囲を把握
        let tempBuffer = buffer
        child.paint(origin: origin, into: &buffer)
        
        // 描画された範囲を検出
        var minRow = buffer.count
        var maxRow = 0
        var minCol = Int.max
        var maxCol = 0
        
        for (index, line) in buffer.enumerated() {
            if index < tempBuffer.count && line != tempBuffer[index] {
                // この行が変更された
                minRow = min(minRow, index)
                maxRow = max(maxRow, index)
                
                // 変更された範囲を検出
                if line.count > origin.x {
                    minCol = min(minCol, origin.x)
                    maxCol = max(maxCol, line.count)
                }
            }
        }
        
        // 背景色を適用
        if minRow <= maxRow {
            for row in minRow...maxRow {
                if row < buffer.count {
                    // 行の内容を背景色で囲む
                    let line = buffer[row]
                    if line.count > origin.x {
                        let startIdx = line.index(line.startIndex, offsetBy: origin.x)
                        let content = String(line[startIdx...])
                        let bgContent = "\u{1B}[\(color.bg)m" + content + "\u{1B}[0m"
                        buffer[row] = String(line[..<startIdx]) + bgContent
                    }
                }
            }
        }
    }
    
    func render(into buffer: inout [String]) {
        child.render(into: &buffer)
    }
}