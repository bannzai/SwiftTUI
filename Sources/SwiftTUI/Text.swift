public struct Text: View {
  let content: String

  public init(_ content: String) {
    self.content = content
  }

  public func render(into buffer: inout [String]) {
    buffer.append(content)
  }
}
