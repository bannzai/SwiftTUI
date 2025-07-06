/// SwiftUIライクなVStack View
public struct VStack<Content: View>: View {
    internal let content: Content
    internal let spacing: Int
    internal let alignment: HorizontalAlignment
    
    public init(
        alignment: HorizontalAlignment = .center,
        spacing: Int = 0,
        @ViewBuilder content: () -> Content
    ) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }
    
    // VStack自体はプリミティブViewなのでbodyは持たない
    public typealias Body = Never
}

// HorizontalAlignmentはFrameModifier.swiftで定義済み

// 内部実装：セルベースのFlexStackへの変換
extension VStack {
    internal var _layoutView: any LayoutView {
        // contentをLayoutViewに変換
        let contentLayoutView = ViewRenderer.renderView(content)
        
        // CellFlexStackとして返す（spacingを渡す）
        return CellFlexStack(.column, spacing: Float(spacing)) {
            // TupleLayoutViewの場合は子要素を展開
            if let tupleLayoutView = contentLayoutView as? TupleLayoutView {
                return tupleLayoutView.views
            } else {
                return [LegacyAnyView(contentLayoutView)]
            }
        }
    }
}