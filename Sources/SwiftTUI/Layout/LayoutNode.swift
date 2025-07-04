import yoga

/// レイアウト計算済みのノードとビューのペア
public struct LayoutNode {
    public let view: any LayoutView
    public let node: YogaNode
    
    public init(view: any LayoutView, node: YogaNode) {
        self.view = view
        self.node = node
    }
}

/// 改良されたLayoutViewプロトコル
public protocol LayoutViewV2: View {
    func makeNode() -> YogaNode
    func paint(layoutNode: YogaNode, origin: (x: Int, y: Int), into buffer: inout [String])
}

extension LayoutViewV2 {
    public func render(into buffer: inout [String]) {
        // デフォルト実装
    }
}