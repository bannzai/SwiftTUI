public struct HStack: View {
  private let children: [AnyView]
  private let spacing: Int

  public init(spacing: Int = 1,
              @ViewBuilder _ content: () -> [AnyView]) {
    self.spacing  = spacing
    self.children = content()
  }

  public func render(into buffer: inout [String]) {
    var line = ""
    for (index, child) in children.enumerated() {
      var childLines: [String] = []
      child.render(into: &childLines)

      line += childLines.first ?? ""

      if index < children.count - 1 {
        line += String(repeating: " ", count: spacing)
      }
    }
    buffer.append(line)
  }

  public func handle(event: KeyboardEvent) -> Bool {
    for child in children where child.handle(event: event) {
      return true
    }
    return false
  }
}
