public protocol LegacyView {
  func render(into buffer: inout [String])

  /// キーイベントを処理したら true を返す（デフォルトは false）
  func handle(event: KeyboardEvent) -> Bool
}

public extension LegacyView {
  func handle(event: KeyboardEvent) -> Bool { false }
}
