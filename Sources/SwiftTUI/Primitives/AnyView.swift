import Foundation

/// 型消去ビュー。`render` だけでなく `handle(event:)` も委譲する。
public struct AnyView: View {

  // MARK: - Stored closures
  private let _render: (inout [String]) -> Void
  private let _handle: (KeyboardEvent) -> Bool

  // MARK: - Init
  public init<V: View>(_ view: V) {
    _render = { buffer in
      var buf = buffer
      view.render(into: &buf)
      buffer = buf
    }
    _handle = { event in
      view.handle(event: event)
    }
  }

  // MARK: - View conformance
  public func render(into buffer: inout [String]) {
    _render(&buffer)
  }

  public func handle(event: KeyboardEvent) -> Bool {
    _handle(event)
  }
}
