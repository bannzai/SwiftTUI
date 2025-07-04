import SwiftTUI

final class TestPaddingView: LayoutView {
  
  private let body = Text("Test padding").padding(5)
  
  func makeNode() -> YogaNode { body.makeNode() }
  func paint(origin:(x:Int,y:Int), into buf:inout [String]) {
    body.paint(origin: origin, into: &buf)
  }
  func render(into buffer: inout [String]) {}
}

@main  
struct TestPadding {
  static func main() {
    RenderLoop.mount { TestPaddingView() }
    dispatchMain()
  }
}