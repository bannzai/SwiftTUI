/// SwiftUIライクなSpacer View
public struct Spacer: View {
  public init() {}

  // Spacer自体はプリミティブViewなのでbodyは持たない
  public typealias Body = Never
}

// 内部実装：既存のLegacySpacerへの変換
extension Spacer {
  internal var _layoutView: any LayoutView {
    LegacySpacer()
  }
}
