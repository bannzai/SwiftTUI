public struct VStack: View {
  private let children: [AnyView]

  public init(@ViewBuilder _ content: () -> [AnyView]) {
    self.children = content()
  }

  public func render(into buffer: inout [String]) {
    for child in children {
      child.render(into: &buffer)
    }
  }
}
