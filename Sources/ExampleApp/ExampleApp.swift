import SwiftTUI
import Foundation

struct CounterView: View {
  @State private var count = 0

  func render(into buffer: inout [String]) {
    buffer.append("Count: \(count)")
    buffer.append("Press ENTER to increment / q + ENTER to quit")
  }

  mutating func increment() { count += 1 }
}

@main
struct ExampleApp {
  static func main() {
    var counter = CounterView()

    RenderLoop.mount { counter }

    // ② 標準入力ループ
    let stdin = FileHandle.standardInput
    while true {
      if let line = readLine(strippingNewline: true) {
        if line.lowercased() == "q" { break }
        counter.increment()          // 状態更新 → 自動再描画
      }
    }
    print("Bye! 👋")
  }
}
