import SwiftTUI
import Dispatch

final class DemoView: LayoutView {

  /// 実際の UI ツリーを 1 つだけ保持
  private let body = VStack {
    HStack {
      Text("🟥").background(.red)
      Text("row").color(.yellow)
    }
    Text("center").background(.blue)
    HStack {
      Text("end")
      Text("→").color(.green)
    }
  }

  // Yoga ノードは body に丸投げ
  func makeNode() -> YogaNode { body.makeNode() }

  // paint も body に丸投げ ――― 重要!!
  func paint(origin: (x: Int, y: Int), into buf: inout [String]) {
    body.paint(origin: origin, into: &buf)
  }

  // View プロトコル互換（未使用だが必須）
  func render(into buffer: inout [String]) { }
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
    let view = DemoView()
    RenderLoop.mount { view }
    dispatchMain()
  }
}
