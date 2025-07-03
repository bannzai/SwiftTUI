import yoga                     // ← .package で入れた product

final class YogaNode {

  // OpaquePointer（nil で落とす）
  private let raw: YGNodeRef

  init() {
    guard let n = YGNodeNew() else { fatalError("YGNodeNew() nil") }
    raw = n
  }
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
    (Int(YGNodeLayoutGetLeft(raw)),
     Int(YGNodeLayoutGetTop(raw)),
     Int(YGNodeLayoutGetWidth(raw)),
     Int(YGNodeLayoutGetHeight(raw)))
  }

  // MARK: – measure
  func setMeasure(_ f: @escaping YGMeasureFunc) {
    YGNodeSetMeasureFunc(raw, f)
  }

  // internal
  var rawPtr: YGNodeRef { raw }
}
