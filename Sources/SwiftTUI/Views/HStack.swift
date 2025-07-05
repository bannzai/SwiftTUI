/// SwiftUIライクなHStack View
public struct HStack<Content: View>: View {
    internal let content: Content
    internal let spacing: Int
    internal let alignment: VerticalAlignment
    
    public init(
        alignment: VerticalAlignment = .center,
        spacing: Int = 0,
        @ViewBuilder content: () -> Content
    ) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }
    
    // HStack自体はプリミティブViewなのでbodyは持たない
    public typealias Body = Never
}

// VerticalAlignmentはFrameModifier.swiftで定義済み

// 内部実装：既存のFlexStackへの変換
extension HStack {
    internal var _layoutView: any LayoutView {
        // contentをLayoutViewに変換
        let contentLayoutView = ViewRenderer.renderView(content)
        
        // FlexStackとして返す（spacingを渡す）
        return FlexStack(.row, spacing: Float(spacing)) {
            // TupleLayoutViewの場合は子要素を展開
            if let tupleLayoutView = contentLayoutView as? TupleLayoutView {
                return tupleLayoutView.views
            } else {
                return [LegacyAnyView(contentLayoutView)]
            }
        }
    }
}