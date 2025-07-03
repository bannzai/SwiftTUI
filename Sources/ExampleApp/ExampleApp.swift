import SwiftTUI

@main
struct ExampleApp {
  static func main() {
    Renderer.render(
      VStack {
        Text("🍣  SwiftTUI へようこそ")
        Text("🚀  VStack が動いています")
        Text("✅  行が縦に並びました！")
      }
    )
  }
}
