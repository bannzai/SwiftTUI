/// Borderを適用するmodifier
public struct BorderModifier: ViewModifier {
    let style: BorderStyle
    let color: Color?
    
    public init(style: BorderStyle = .single, color: Color? = nil) {
        self.style = style
        self.color = color
    }
    
    public func body(content: Content) -> some View {
        // 一時的にコンテンツをそのまま返す
        // TODO: 実際のborder実装
        content
    }
}

/// ボーダースタイル
public enum BorderStyle {
    case single
    case double
    case rounded
    case thick
}

// View拡張：border modifier
public extension View {
    /// デフォルトのボーダー
    func border() -> some View {
        modifier(BorderModifier())
    }
    
    /// スタイルを指定したボーダー
    func border(_ style: BorderStyle, color: Color? = nil) -> some View {
        modifier(BorderModifier(style: style, color: color))
    }
}