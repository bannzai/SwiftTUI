import SwiftTUI

@main
struct ExampleApp {
  static func main() {
    Renderer.render(
      VStack {
        Text("📦  VStack + HStack デモ")
        HStack(spacing: 3) {
          Text("🐶 Dog")
          Text("🐱 Cat")
          Text("🦊 Fox")
        }
        Text("— 横に 3 つ並びました —")
      }
    )
  }
}
