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

  public func handle(event: KeyboardEvent) -> Bool {
    for child in children where child.handle(event: event) {
      return true
    }
    return false
  }
}
