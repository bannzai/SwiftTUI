import yoga

public final class YogaNode {

  // MARK: storage
  fileprivate let raw: YGNodeRef            // 実ノード

  // MARK: init / deinit
  public init() {
    guard let p = YGNodeNew() else { fatalError("YGNodeNew nil!") }
    raw = p
  }
  deinit { YGNodeFree(raw) }

  /// DEBUG 用：既存 raw を包む
  init(raw: YGNodeRef) { self.raw = raw }

  // MARK: expose raw
  /// C-API を直接呼びたいデバッグ・トラバース用
  public var rawPtr: YGNodeRef { raw }      // ←★ これを追加

  // MARK: children
  public func insert(child: YogaNode) {
    YGNodeInsertChild(raw, child.raw, Int(YGNodeGetChildCount(raw)))
  }

  // MARK: style setters
  public func flexDirection(_ d: YGFlexDirection) {
    YGNodeStyleSetFlexDirection(raw, d)
  }
  public func padding(all v: Float) {
    YGNodeStyleSetPadding(raw, YGEdge.all, v)
  }
  public func setSize(width w: Float, height h: Float) {
    YGNodeStyleSetWidth(raw,  w)
    YGNodeStyleSetHeight(raw, h)
  }
  public func setMinHeight(_ h: Float) {
    YGNodeStyleSetMinHeight(raw, h)
  }

  // MARK: layout
  public func calculate(width: Float = .nan, height: Float = .nan) {
    YGNodeCalculateLayout(raw, width, height, YGDirection.LTR)
  }

  // MARK: frame (NaN→0)
  public var frame: (x:Int,y:Int,w:Int,h:Int) {
    func safe(_ v: Float) -> Int { v.isFinite ? Int(v) : 0 }
    return (safe(YGNodeLayoutGetLeft(raw)),
            safe(YGNodeLayoutGetTop(raw)),
            safe(YGNodeLayoutGetWidth(raw)),
            safe(YGNodeLayoutGetHeight(raw)))
  }
}
