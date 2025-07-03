import SwiftTUI

struct CounterView: View {
  @State private var count = 0

  mutating func increment() { count += 1 }

  func render(into buffer: inout [String]) {
    buffer.append("Count: \(count)")
    buffer.append("Press ENTER to increment / q + ENTER to quit")
  }
}

@main
struct ExampleApp {
  static func main() {
    var counter = CounterView()

    RenderLoop.mount { counter }

    while let line = readLine(strippingNewline: true) {
      if line.lowercased() == "q" { break }
      counter.increment()
    }
    print("Bye! 👋")
  }
}
