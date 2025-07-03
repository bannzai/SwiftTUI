import yoga                     // ← .package で入れた product

public final class YogaNode {

  // OpaquePointer（nil で落とす）
  private let raw: YGNodeRef

  init() {
    guard let n = YGNodeNew() else { fatalError("YGNodeNew() nil") }
    raw = n
  }

  /// internal: wrap existing raw pointer（DEBUG 用）
  init(raw: YGNodeRef) { self.raw = raw }
  
  deinit { YGNodeFree(raw) }

  // MARK: – children
  func insert(child: YogaNode) {
    let idx = Int(YGNodeGetChildCount(raw))      // Swift 側は Int
    YGNodeInsertChild(raw, child.raw, idx)
  }

  // MARK: – style
  func flexDirection(_ dir: YGFlexDirection) {
    YGNodeStyleSetFlexDirection(raw, dir)        // .row / .column
  }

  func padding(all v: Float) {
    YGNodeStyleSetPadding(raw, YGEdge.all, v)    // ← ドット記法
  }

  // MARK: – layout
  func calculate(width: Float = .nan,
                 height: Float = .nan) {
    YGNodeCalculateLayout(raw, width, height, YGDirection.LTR)
  }

  // MARK: – result
  var frame: (x: Int, y: Int, w: Int, h: Int) {
    // NaN → 0 にフォールバックして Int 変換
    func safeInt(_ f: Float) -> Int { f.isFinite ? Int(f) : 0 }
    let l = safeInt(YGNodeLayoutGetLeft(raw))
    let t = safeInt(YGNodeLayoutGetTop(raw))
    let w = safeInt(YGNodeLayoutGetWidth(raw))
    let h = safeInt(YGNodeLayoutGetHeight(raw))
    return (l, t, w, h)
  }

  // MARK: – measure
  func setMeasure(_ f: @escaping YGMeasureFunc) {
    YGNodeSetMeasureFunc(raw, f)
  }

  // internal
  var rawPtr: YGNodeRef { raw }

  func setSize(width w: Float, height h: Float) {
    YGNodeStyleSetWidth(raw, w)
    YGNodeStyleSetHeight(raw, h)
  }

  func setMinHeight(_ h: Float) {
    YGNodeStyleSetMinHeight(raw, h)
  }
}
