/// Backgroundを適用するmodifier
public struct BackgroundModifier<Background: View>: ViewModifier {
  let background: Background

  public init(background: Background) {
    self.background = background
  }

  public func body(content: Content) -> some View {
    // 一時的にコンテンツをそのまま返す
    // TODO: 実際のbackground実装
    content
  }
}

// View拡張：background modifier
extension View {
  /// 色の背景
  public func background(_ color: Color) -> some View {
    modifier(BackgroundModifier(background: Color.ColorView(color)))
  }

  /// カスタムViewの背景
  public func background<V: View>(@ViewBuilder _ content: () -> V) -> some View {
    modifier(BackgroundModifier(background: content()))
  }
}

// Color用のView
extension Color {
  struct ColorView: View {
    let color: Color

    init(_ color: Color) {
      self.color = color
    }

    public typealias Body = Never
  }
}
