/// SwiftUIライクなText View
public struct Text: View {
    private let content: String
    private var modifiers: TextModifiers = TextModifiers()
    
    public init(_ content: String) {
        self.content = content
    }
    
    public init<S: StringProtocol>(_ content: S) {
        self.content = String(content)
    }
    
    // Text自体はプリミティブViewなのでbodyは持たない
    public typealias Body = Never
}

// テキスト用のモディファイア設定
private struct TextModifiers {
    var foregroundColor: Color?
    var backgroundColor: Color?
    var bold: Bool = false
    var italic: Bool = false
    var underline: Bool = false
}

// ViewModifier
public extension Text {
    func foregroundColor(_ color: Color?) -> Text {
        var copy = self
        copy.modifiers.foregroundColor = color
        return copy
    }
    
    func background(_ color: Color) -> Text {
        var copy = self
        copy.modifiers.backgroundColor = color
        return copy
    }
    
    func bold() -> Text {
        var copy = self
        copy.modifiers.bold = true
        return copy
    }
    
    func italic() -> Text {
        var copy = self
        copy.modifiers.italic = true
        return copy
    }
    
    func underline() -> Text {
        var copy = self
        copy.modifiers.underline = true
        return copy
    }
}

// 内部実装：既存のLegacyText LayoutViewへの変換
extension Text {
    internal var _layoutView: any LayoutView {
        // 既存のLegacyTextを使用
        let oldText = LegacyText(content)
        
        // モディファイアを適用
        var result = oldText
        if let fg = modifiers.foregroundColor {
            result = result.color(fg)
        }
        if let bg = modifiers.backgroundColor {
            result = result.background(bg)
        }
        if modifiers.bold {
            result = result.bold()
        }
        
        return result
    }
}