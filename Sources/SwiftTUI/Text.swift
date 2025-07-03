public struct Text {
  let content: String

  public init(_ content: String) {
    self.content = content
  }

  public func render() {
    print(content)
  }
}
