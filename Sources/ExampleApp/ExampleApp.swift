import SwiftTUI
import Dispatch

final class DemoView: LayoutView {

  private let body = VStack {
    HStack {
      Text("Left")
      Spacer()                // 空き領域
      Text("Right")
    }
    .padding(2)                 // VStack の子 HStack に 2 マス余白

    Text("bottom").background(.blue)
  }

  func makeNode() -> YogaNode { body.makeNode() }
  func paint(origin:(x:Int,y:Int), into buf:inout[String]) {
    body.paint(origin: origin, into: &buf)
  }
  func render(into buffer: inout [String]) {}
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


@main
struct ExampleApp {
  static func main() {
    RenderLoop.mount { DemoView() }
    dispatchMain()
  }
}
