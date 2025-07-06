import yoga

/// セルベースのFlexStack実装
final class CellFlexStack: CellLayoutView {
    enum Axis { case column, row }
    private let axis: Axis
    private let children: [LegacyAnyView]
    private let spacing: Float
    private var calculatedNode: YogaNode?
    
    init(_ axis: Axis, spacing: Float = 0, @LegacyViewBuilder _ c: () -> [LegacyAnyView]) {
        self.axis = axis
        self.spacing = spacing
        self.children = c()
    }
    
    // MARK: YogaNode
    func makeNode() -> YogaNode {
        let n = YogaNode()
        n.flexDirection(axis == .column ? .column : .row)
        
        // Set gap (spacing) if specified
        if spacing > 0 {
            n.setGap(spacing, axis == .column ? .column : .row)
        }
        
        children.forEach { n.insert(child: $0.makeNode()) }
        self.calculatedNode = n
        return n
    }
    
    // MARK: Paint Cells
    func paintCells(origin: (x: Int, y: Int), into buffer: inout CellBuffer) {
        // Use the calculated node if available, otherwise create a new one
        let node = calculatedNode ?? makeNode()
        
        // If we don't have layout information, we need to calculate it
        if YGNodeLayoutGetWidth(node.rawPtr) == 0 {
            // Fallback: calculate with a default width
            node.calculate(width: 80)
        }
        
        // Paint children at their calculated positions
        let cnt = Int(YGNodeGetChildCount(node.rawPtr))
        for i in 0..<cnt {
            guard let raw = YGNodeGetChild(node.rawPtr, Int(i)) else { continue }
            
            // Float値の安全な変換
            let left = YGNodeLayoutGetLeft(raw)
            let top = YGNodeLayoutGetTop(raw)
            
            // NaNやInfiniteのチェック
            guard left.isFinite && top.isFinite else { continue }
            
            let dx = Int(left.rounded())
            let dy = Int(top.rounded())
            let childOrigin = (x: origin.x + dx, y: origin.y + dy)
            
            // 子ビューを取得
            let child = children[i]
            
            if let cellChild = child as? CellLayoutView {
                cellChild.paintCells(origin: childOrigin, into: &buffer)
            } else {
                // 従来のLayoutViewの場合はアダプターを使用
                let adapter = CellLayoutAdapter(child)
                adapter.paintCells(origin: childOrigin, into: &buffer)
            }
        }
    }
    
    // MARK: Legacy paint
    func paint(origin: (x: Int, y: Int), into buf: inout [String]) {
        // CellLayoutViewのデフォルト実装を使用
        var cellBuffer = CellBuffer(width: 200, height: 100)
        paintCells(origin: origin, into: &cellBuffer)
        
        let lines = cellBuffer.toANSILines()
        for (index, line) in lines.enumerated() {
            let row = origin.y + index
            if row >= 0 {
                while buf.count <= row { buf.append("") }
                buf[row] = line
            }
        }
    }
    
    // MARK: Render
    func render(into buffer: inout [String]) {
        for child in children {
            child.render(into: &buffer)
        }
    }
}