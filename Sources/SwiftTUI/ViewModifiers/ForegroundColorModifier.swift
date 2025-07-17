/// ForegroundColorを適用するmodifier
public struct ForegroundColorModifier: ViewModifier {
  let color: Color?

  public init(color: Color?) {
    self.color = color
  }

  public func body(content: Content) -> some View {
    // 一時的にコンテンツをそのまま返す
    // TODO: 実際のforegroundColor実装
    content
  }
}

// View拡張：foregroundColor modifier
extension View {
  /// 前景色（テキスト色）を設定
  public func foregroundColor(_ color: Color?) -> some View {
    modifier(ForegroundColorModifier(color: color))
  }
}
