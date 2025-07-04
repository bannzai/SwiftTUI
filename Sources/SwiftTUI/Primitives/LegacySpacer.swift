import yoga

/// 伸縮する空白
public final class LegacySpacer: LayoutView {

  public init() {}

  // 幅・高さ 0、flexGrow=1
  public func makeNode() -> YogaNode {
    let n = YogaNode()
    n.setSize(width: 0, height: 0)
    n.setFlexGrow(1)
    return n
  }

  public func paint(origin: (x: Int, y: Int), into buf: inout [String]) {
    // 描画するものは無し
  }

  // View プロトコル互換
  public func render(into buffer: inout [String]) {}
}
