/// 「Yoga ノードを返せる」＋「座標付き描画ができる」View
public protocol LayoutView: View {
  func makeNode() -> YogaNode
  func paint(origin: (x: Int, y: Int), into buffer: inout [String])
}

extension LayoutView {
  // View 要件を満たすだけ。RenderLoop では使わない
  public func render(into buffer: inout [String]) {
    // no-op で OK
  }
}
