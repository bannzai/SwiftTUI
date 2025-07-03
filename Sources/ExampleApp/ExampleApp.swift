import SwiftTUI
import Dispatch

final class DemoView: LayoutView {

  func makeNode() -> YogaNode {
    VStack {
      HStack {
        Text("🟥").background(.red)
        Text("row").color(.yellow)
      }
      Text("center").background(.blue)
      HStack {
        Text("end")
        Text("→").color(.green)
      }
    }.makeNode()
  }

  func paint(origin: (x: Int, y: Int), into buf: inout [String]) {
    // FlexStack が再帰的に paint するので何もしない
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
