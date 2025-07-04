/// SwiftUIライクなVStack View
public struct VStack<Content: View>: View {
    private let content: Content
    private let spacing: Int
    private let alignment: HorizontalAlignment
    
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

/// 水平方向の配置
public enum HorizontalAlignment {
    case leading
    case center
    case trailing
}

// 内部実装：既存のFlexStackへの変換
extension VStack {
    internal var _layoutView: any LayoutView {
        // contentをLayoutViewに変換
        let contentLayoutView = ViewRenderer.renderView(content)
        
        // FlexStackとして返す
        return FlexStack(.column) {
            // TupleLayoutViewの場合は子要素を展開
            if let tupleLayoutView = contentLayoutView as? TupleLayoutView {
                return tupleLayoutView.views
            } else {
                return [LegacyAnyView(contentLayoutView)]
            }
        }
    }
}