/// Viewの外観や動作を変更するモディファイア
public protocol ViewModifier {
    associatedtype Body: View
    
    /// モディファイアを適用してViewを変換
    func body(content: Content) -> Body
    
    /// モディファイアが適用される元のコンテンツ
    typealias Content = _ViewModifier_Content<Self>
}

/// ViewModifierに渡されるコンテンツ
public struct _ViewModifier_Content<Modifier: ViewModifier>: View {
    let modifier: Modifier
    let view: AnyView
    
    public typealias Body = Never
}

/// ModifiedContent: ViewにModifierを適用した結果
public struct ModifiedContent<Content: View, Modifier: ViewModifier>: View {
    let content: Content
    let modifier: Modifier
    
    public init(content: Content, modifier: Modifier) {
        self.content = content
        self.modifier = modifier
    }
    
    public var body: some View {
        modifier.body(content: _ViewModifier_Content(modifier: modifier, view: AnyView(content)))
    }
}

// View拡張：modifierメソッド
public extension View {
    /// ViewModifierを適用
    func modifier<M: ViewModifier>(_ modifier: M) -> ModifiedContent<Self, M> {
        ModifiedContent(content: self, modifier: modifier)
    }
}