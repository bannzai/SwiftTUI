/// Frameを適用するmodifier
public struct FrameModifier: ViewModifier {
  let width: Float?
  let height: Float?
  let alignment: Alignment

  public init(width: Float? = nil, height: Float? = nil, alignment: Alignment = .center) {
    self.width = width
    self.height = height
    self.alignment = alignment
  }

  public func body(content: Content) -> some View {
    // 一時的にコンテンツをそのまま返す
    // TODO: 実際のframe実装
    content
  }
}

/// アライメント
public struct Alignment {
  let horizontal: HorizontalAlignment
  let vertical: VerticalAlignment

  public init(horizontal: HorizontalAlignment, vertical: VerticalAlignment) {
    self.horizontal = horizontal
    self.vertical = vertical
  }

  public static let center = Alignment(horizontal: .center, vertical: .center)
  public static let leading = Alignment(horizontal: .leading, vertical: .center)
  public static let trailing = Alignment(horizontal: .trailing, vertical: .center)
  public static let top = Alignment(horizontal: .center, vertical: .top)
  public static let bottom = Alignment(horizontal: .center, vertical: .bottom)
  public static let topLeading = Alignment(horizontal: .leading, vertical: .top)
  public static let topTrailing = Alignment(horizontal: .trailing, vertical: .top)
  public static let bottomLeading = Alignment(horizontal: .leading, vertical: .bottom)
  public static let bottomTrailing = Alignment(horizontal: .trailing, vertical: .bottom)
}

/// 水平アライメント
public enum HorizontalAlignment {
  case leading
  case center
  case trailing
}

/// 垂直アライメント
public enum VerticalAlignment {
  case top
  case center
  case bottom
}

// View拡張：frame modifier
extension View {
  /// サイズを指定
  public func frame(width: Float? = nil, height: Float? = nil, alignment: Alignment = .center)
    -> some View
  {
    modifier(FrameModifier(width: width, height: height, alignment: alignment))
  }

  /// 幅のみ指定（Int版）
  public func frame(width: Int) -> some View {
    frame(width: Float(width), height: nil)
  }

  /// 高さのみ指定（Int版）
  public func frame(height: Int) -> some View {
    frame(width: nil, height: Float(height))
  }

  /// 幅と高さを指定（Int版）
  public func frame(width: Int, height: Int) -> some View {
    frame(width: Float(width), height: Float(height))
  }
}
