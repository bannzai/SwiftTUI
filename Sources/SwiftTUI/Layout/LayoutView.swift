/// 「Yoga ノードを返せる」＋「座標付き描画ができる」View
protocol LayoutView: View {
  func makeNode() -> YogaNode
  func paint(origin: (x: Int, y: Int), into buffer: inout [String])
}
