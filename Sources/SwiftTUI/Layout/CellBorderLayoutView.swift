import yoga

/// セルベースのボーダーレイアウトビュー
internal struct CellBorderLayoutView: CellLayoutView {
    let child: any LayoutView
    let style: BorderStyle
    let color: Color?
    private let inset: Float = 1
    
    init(child: any LayoutView, style: BorderStyle = .single, color: Color? = nil) {
        self.child = child
        self.style = style
        self.color = color
    }
    
    func makeNode() -> YogaNode {
        let node = YogaNode()
        node.setPadding(inset, .all)
        
        let childNode = child.makeNode()
        node.insert(child: childNode)
        
        // Don't recalculate the child here - let the parent handle it
        
        return node
    }
    
    func paintCells(origin: (x: Int, y: Int), into buffer: inout CellBuffer) {
        // First, paint the child to a temporary buffer to get its actual size
        var tempBuffer = CellBuffer(width: buffer.width, height: buffer.height)
        
        if let cellChild = child as? CellLayoutView {
            cellChild.paintCells(origin: (0, 0), into: &tempBuffer)
        } else {
            let adapter = CellLayoutAdapter(child)
            adapter.paintCells(origin: (0, 0), into: &tempBuffer)
        }
        
        // Find the actual content bounds
        var minX = Int.max
        var maxX = 0
        var minY = Int.max
        var maxY = 0
        for row in 0..<tempBuffer.height {
            for col in 0..<tempBuffer.width {
                if let cell = tempBuffer.getCell(row: row, col: col), cell.character != " " || cell.backgroundColor != nil {
                    minX = min(minX, col)
                    maxX = max(maxX, col)
                    minY = min(minY, row)
                    maxY = max(maxY, row)
                }
            }
        }
        
        // Calculate border dimensions
        let contentWidth = maxX >= minX ? maxX - minX + 1 : 0
        let contentHeight = maxY >= minY ? maxY - minY + 1 : 0
        let width = contentWidth + 2  // Add 2 for border
        let height = contentHeight + 2  // Add 2 for border
        
        // ボーダーを描画
        bufferDrawBorder(
            row: origin.y,
            col: origin.x,
            width: width,
            height: height,
            style: style,
            color: color,
            into: &buffer
        )
        
        // Copy the content from temp buffer to the main buffer inside the border
        let childOrigin = (x: origin.x + 1, y: origin.y + 1)
        
        // Copy from the found content area, not from (0,0)
        for row in 0..<contentHeight {
            for col in 0..<contentWidth {
                let srcRow = minY + row
                let srcCol = minX + col
                if let cell = tempBuffer.getCell(row: srcRow, col: srcCol) {
                    let dstRow = childOrigin.y + row
                    let dstCol = childOrigin.x + col
                    buffer.setCell(row: dstRow, col: dstCol, cell: cell)
                }
            }
        }
    }
    
    func render(into buffer: inout [String]) {
        child.render(into: &buffer)
    }
    
    func handle(event: KeyboardEvent) -> Bool {
        child.handle(event: event)
    }
}