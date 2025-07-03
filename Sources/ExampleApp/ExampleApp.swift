import SwiftTUI
import Dispatch

final class DemoView: LayoutView {

  // ① “中身” を 1 つ持っておく
  private let body: VStack = VStack {
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
  func makeNode() -> YogaNode { body.makeNode() }

  func paint(origin: (x: Int, y: Int), into buf: inout [String]) {
    body.paint(origin: origin, into: &buf)
  }

  func render(into buffer: inout [String]) { }       // protocol conformance
}

@main
struct ExampleApp {
  static func main() {
    let view = DemoView()
    RenderLoop.mount { view }
    dispatchMain()
  }
}
