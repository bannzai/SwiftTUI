import yoga

public final class YogaNode {

  fileprivate let raw: YGNodeRef
  private var retainedChildren: [YogaNode] = []   // ← ★ 子を保持

  public init() {
    guard let p = YGNodeNew() else { fatalError("YGNodeNew nil!") }
    raw = p
  }
  deinit { YGNodeFree(raw) }

  init(raw: YGNodeRef) { self.raw = raw }

  // ── expose for debug ──
  public var rawPtr: YGNodeRef { raw }

  // ── children ────────────────────────────────────────────────────────
  public func insert(child: YogaNode) {
    retainedChildren.append(child)              // ← ★ retain
    YGNodeInsertChild(raw, child.raw, Int(YGNodeGetChildCount(raw)))
  }
  
  public func removeAllChildren() {
    // Yogaから子ノードを削除
    YGNodeRemoveAllChildren(raw)
    // 保持している参照もクリア
    retainedChildren.removeAll()
  }

  // ── style setters (unchanged) ───────────────────────────────────────
  public func flexDirection(_ d: YGFlexDirection) { YGNodeStyleSetFlexDirection(raw, d) }
  public func padding(all v: Float)               { YGNodeStyleSetPadding(raw, YGEdge.all, v) }
  public func setSize(width w: Float, height h: Float) {
    YGNodeStyleSetWidth(raw,  w); YGNodeStyleSetHeight(raw, h)
  }
  public func setMinHeight(_ h: Float)            { YGNodeStyleSetMinHeight(raw, h) }

  // ── layout & frame (unchanged) ───────────────────────────────────────
  public func calculate(width: Float = .nan, height: Float = .nan) {
    YGNodeCalculateLayout(raw, width, height, YGDirection.LTR)
  }
  public var frame:(x:Int,y:Int,w:Int,h:Int) {
    func s(_ v: Float)->Int{ v.isFinite ? Int(v) : 0 }
    return (s(YGNodeLayoutGetLeft(raw)), s(YGNodeLayoutGetTop(raw)),
            s(YGNodeLayoutGetWidth(raw)), s(YGNodeLayoutGetHeight(raw)))
  }


  // MARK: – Flex
  public func setFlexGrow(_ g: Float) {
    YGNodeStyleSetFlexGrow(raw, g)
  }
  public func setFlexShrink(_ s: Float) {
    YGNodeStyleSetFlexShrink(raw, s)
  }

  public enum Edge { case all, horizontal, vertical, top, left, bottom, right }

  public func setPadding(_ val: Float, _ edge: Edge = .all) {
    switch edge {
    case .all:        YGNodeStyleSetPadding(raw, YGEdge.all, val)
    case .horizontal: YGNodeStyleSetPadding(raw, YGEdge.horizontal, val)
    case .vertical:   YGNodeStyleSetPadding(raw, YGEdge.vertical, val)
    case .top:        YGNodeStyleSetPadding(raw, YGEdge.top, val)
    case .left:       YGNodeStyleSetPadding(raw, YGEdge.left, val)
    case .bottom:     YGNodeStyleSetPadding(raw, YGEdge.bottom, val)
    case .right:      YGNodeStyleSetPadding(raw, YGEdge.right, val)
    }
  }
  
  // MARK: - Gap (spacing between flex items)
  public func setGap(_ gap: Float, _ gutter: YGGutter = .column) {
    YGNodeStyleSetGap(raw, gutter, gap)
  }
}
