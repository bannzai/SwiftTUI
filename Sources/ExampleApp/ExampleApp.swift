import SwiftTUI
import Dispatch

struct CounterView: View {
  @State private var count = 0

  func render(into buffer: inout [String]) {
    buffer.append("Count: \(count)")
    buffer.append("Press ‘i’ to increment / ESC to quit")
  }

  func handle(event: KeyboardEvent) -> Bool {
    switch event.key {
    case .character("i"):
      count += 1           // @State → RenderLoop.scheduleRedraw()
      return true          // ← handled
    case .escape:
      exit(0)
    case _:
      return false
    }
  }
}

@main
struct ExampleApp {
  static func main() {
    var counter = CounterView()
    RenderLoop.mount { counter }
    Dispatch.dispatchMain()
  }
}
