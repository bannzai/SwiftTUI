/// SwiftUIライクなScrollView
public struct ScrollView<Content: View>: View {
  internal let axes: Axis.Set
  internal let showsIndicators: Bool
  internal let content: Content

  public init(
    _ axes: Axis.Set = .vertical, showsIndicators: Bool = true, @ViewBuilder content: () -> Content
  ) {
    self.axes = axes
    self.showsIndicators = showsIndicators
    self.content = content()
  }

  // ScrollView自体はプリミティブViewなのでbodyは持たない
  public typealias Body = Never
}

/// スクロール方向を表すAxis
public struct Axis {
  public struct Set: OptionSet {
    public let rawValue: Int

    public init(rawValue: Int) {
      self.rawValue = rawValue
    }

    public static let horizontal = Set(rawValue: 1 << 0)
    public static let vertical = Set(rawValue: 1 << 1)
  }
}

// 内部実装：ScrollLayoutViewへの変換
extension ScrollView {
  internal var _layoutView: any LayoutView {
    // contentをLayoutViewに変換
    let contentLayoutView = ViewRenderer.renderView(content)

    // ScrollLayoutViewとして返す
    return ScrollLayoutView(
      axes: axes,
      showsIndicators: showsIndicators,
      child: contentLayoutView
    )
  }
}
