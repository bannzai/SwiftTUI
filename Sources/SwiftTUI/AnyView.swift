public struct AnyView: View {
  private let _render: (inout [String]) -> Void

  public init<V: View>(_ view: V) {
    _render = { view.render(into: &$0) }
  }

  public func render(into buffer: inout [String]) {
    _render(&buffer)
  }
}
