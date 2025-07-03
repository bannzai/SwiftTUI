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
}
