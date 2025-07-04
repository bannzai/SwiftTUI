public enum Renderer {
  public static func render<V: LegacyView>(_ root: V) {
    var buffer: [String] = []
    root.render(into: &buffer)
    for line in buffer {
      print(line)
    }
  }
}
