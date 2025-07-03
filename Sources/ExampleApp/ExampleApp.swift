import SwiftTUI
import Dispatch

struct CounterView: View {
  @State private var count = 0

  func render(into buffer: inout [String]) {
    buffer.append("Count: \(count)")
    buffer.append("Press 'i' to increment / ESC で終了")
  }

  func handle(event: KeyboardEvent) -> Bool {
    switch event.key {
    case .character("i"):
      count += 1          // @State → scheduleRedraw()
      return true
    case .escape:
      // アプリ終了フラグを立てても良い
      return false
    default:
      return false
    }
  }
}

@main
struct ExampleApp {
  static func main() {
    RenderLoop.mount { CounterView() }
    // 以後は InputLoop が非同期で動くためメインスレッドをブロックしない
    Dispatch.dispatchMain()
  }
}
