public protocol View {
  func render(into buffer: inout [String])
}
