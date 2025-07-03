//  Sources/SwiftTUI/Core/AnyView.swift
import yoga

/// 型消去 + LayoutView ブリッジ + デバッグ
public struct AnyView: View, LayoutView {

  // クロージャ保持
  private let _render : (inout [String]) -> Void
  private let _handle : (KeyboardEvent) -> Bool
  private let _make   : () -> YogaNode
  private let _paint  : ((x: Int, y: Int), inout [String]) -> Void

  // --- イニシャライザ ---------------------------------------------------
  public init<V: View>(_ view: V) {

    // View→render/handle は以前と同じ
    _render = { buf in var b = buf; view.render(into: &b); buf = b }
    _handle = { ev in view.handle(event: ev) }

    if let lv = view as? LayoutView {
      // ------ LayoutView を包めた場合 ------
      if RenderLoop.DEBUG {
        print("[DEBUG] AnyView wraps LayoutView:", type(of: view))
      }
      _make  = {
        let n = lv.makeNode()
        if RenderLoop.DEBUG {
          let f = n.frame
          print("[DEBUG]  └ makeNode size (w\(f.w)×h\(f.h))")
        }
        return n
      }
      _paint = { origin, buf in
        lv.paint(origin: origin, into: &buf)
      }
    } else {
      // ------ LayoutView でない場合 --------
      if RenderLoop.DEBUG {
        print("[DEBUG] AnyView wraps NON-LayoutView:", type(of: view))
      }
      _make  = { YogaNode() }                    // 幅0×高0
      _paint = { _, _ in }
    }
  }

  // View
  public func render(into buf: inout [String]) { _render(&buf) }
  public func handle(event: KeyboardEvent) -> Bool { _handle(event) }

  // LayoutView
  public func makeNode() -> YogaNode { _make() }
  public func paint(origin: (x: Int, y: Int),
                    into buf: inout [String]) { _paint(origin, &buf) }
}
