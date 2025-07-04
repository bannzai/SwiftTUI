/// SwiftUIライクなHStack View
public struct HStack<Content: View>: View {
    private let content: Content
    private let spacing: Int
    private let alignment: VerticalAlignment
    
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

/// 垂直方向の配置
public enum VerticalAlignment {
    case top
    case center
    case bottom
}

// 内部実装：既存のFlexStackへの変換
extension HStack {
    internal var _layoutView: any LayoutView {
        // contentをLayoutViewに変換
        let contentLayoutView = ViewRenderer.renderView(content)
        
        // FlexStackとして返す
        return FlexStack(.row) {
            // TupleLayoutViewの場合は子要素を展開
            if let tupleLayoutView = contentLayoutView as? TupleLayoutView {
                return tupleLayoutView.views
            } else {
                return [LegacyAnyView(contentLayoutView)]
            }
        }
    }
}