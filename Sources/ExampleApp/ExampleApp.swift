// Sources/ExampleApp/main.swift
import SwiftTUI
import Dispatch           // dispatchMain()

// ① View を class にする（参照型）
final class CounterView: View {

  @State private var count = 0

  func render(into buffer: inout [String]) {
    buffer.append("Count: \(count)")
    buffer.append("Press 'i' to increment, ESC to quit")
  }

  func handle(event: KeyboardEvent) -> Bool {
    switch event.key {
    case .character("i"):
      count += 1
      print("[DEBUG] incremented to", count)
      return true                    // handled
    case .escape:
      print("[DEBUG] escape pressed, exiting")
      exit(0)
    case _:
      return false
    }
  }
}

@main
struct ExampleApp {
  static func main() {
    // ② インスタンスは 1 個だけ
    let counter = CounterView()

    // ③ クロージャは “常に同じ参照” を返す
    RenderLoop.mount { counter }

    // ④ GCD イベントループへ
    dispatchMain()
  }
}
