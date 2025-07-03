// Sources/SwiftTUI/Core/AnyView.swift
import Foundation
import yoga                       // LayoutView 用に必要

public struct AnyView: View, LayoutView {

  // --- クロージャを保持 -------------------------------------------------
  private let _render : (inout [String]) -> Void
  private let _handle : (KeyboardEvent) -> Bool
  private let _make   : () -> YogaNode
  private let _paint  : ((x: Int, y: Int), inout [String]) -> Void

  // --- 汎用イニシャライザ ---------------------------------------------
  public init<V: View>(_ view: V) {
    _render = { buf in var b = buf; view.render(into: &b); buf = b }
    _handle = { ev in view.handle(event: ev) }

    if let lv = view as? LayoutView {
      // LayoutView を包める場合
      _make  = { lv.makeNode() }
      _paint = { origin, buf in
        var b = buf; lv.paint(origin: origin, into: &b); buf = b
      }
    } else {
      // LayoutView でない場合は「サイズ 0」でダミー化
      _make  = { YogaNode() }
      _paint = { _, _ in }
    }
  }

  // --- View conformance -------------------------------------------------
  public func render(into buf: inout [String]) { _render(&buf) }
  public func handle(event: KeyboardEvent) -> Bool { _handle(event) }

  // --- LayoutView conformance ------------------------------------------
  public func makeNode() -> YogaNode { _make() }
  public func paint(origin: (x: Int, y: Int),
                    into buf: inout [String]) { _paint(origin, &buf) }
}
