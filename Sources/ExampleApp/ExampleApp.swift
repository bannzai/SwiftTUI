import SwiftTUI
import Foundation

final class DemoView: LayoutView {

  private let body = LegacyVStack {
    LegacyHStack {
      LegacyText("Left")
      LegacySpacer()
      LegacyText("Right")
    }
    .padding(1)
    .border()             // ← 枠を付ける

    LegacyText("bottom").background(.blue).border()
  }

  func makeNode() -> YogaNode { body.makeNode() }
  func paint(origin:(x:Int,y:Int), into buf:inout [String]) {
    body.paint(origin: origin, into: &buf)
  }
  func render(into buffer: inout [String]) {}
}

// @main  // SwiftUILikeExampleの@mainと衝突を避けるため一時的にコメントアウト
struct ExampleApp {
  static func main() {
    RenderLoop.mount { DemoView() }
    RunLoop.main.run()
  }
}


extension DemoView {
  func handle(event: KeyboardEvent) -> Bool {
    switch event.key {
    case .character("q"), .escape:
      RenderLoop.shutdown()          // ← 安全終了
      return true
    default:
      return false
    }
  }
}
