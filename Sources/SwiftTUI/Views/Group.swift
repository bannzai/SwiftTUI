/// SwiftUIライクなGroup View
/// 複数のViewを論理的にグループ化するが、レイアウトには影響しない
public struct Group<Content: View>: View {
  internal let content: Content

  public init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  public var body: some View {
    content
  }
}
