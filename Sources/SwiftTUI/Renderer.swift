public enum Renderer {
  public static func render<V: View>(_ root: V) {
    var buffer: [String] = []
    root.render(into: &buffer)
    for line in buffer {
      print(line)
    }
  }
}
