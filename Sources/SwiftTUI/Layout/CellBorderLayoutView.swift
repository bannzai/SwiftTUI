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
        
        return node
    }
    
    func paintCells(origin: (x: Int, y: Int), into buffer: inout CellBuffer) {
        // 子ビューのサイズを取得
        let node = makeNode()
        if YGNodeLayoutGetWidth(node.rawPtr) == 0 {
            node.calculate(width: 80)
        }
        // Float値の安全な変換
        let widthFloat = YGNodeLayoutGetWidth(node.rawPtr)
        let heightFloat = YGNodeLayoutGetHeight(node.rawPtr)
        
        // NaNやInfiniteのチェック
        guard widthFloat.isFinite && heightFloat.isFinite else { return }
        
        let width = Int(widthFloat.rounded())
        let height = Int(heightFloat.rounded())
        
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
        
        // 子ビューを描画（padding分のオフセット付き）
        let childOrigin = (x: origin.x + 1, y: origin.y + 1)
        
        if let cellChild = child as? CellLayoutView {
            cellChild.paintCells(origin: childOrigin, into: &buffer)
        } else {
            // 従来のLayoutViewの場合はアダプターを使用
            let adapter = CellLayoutAdapter(child)
            adapter.paintCells(origin: childOrigin, into: &buffer)
        }
    }
    
    func render(into buffer: inout [String]) {
        child.render(into: &buffer)
    }
    
    func handle(event: KeyboardEvent) -> Bool {
        child.handle(event: event)
    }
}