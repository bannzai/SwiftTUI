public protocol LegacyView {
  func render(into buffer: inout [String])

  /// キーイベントを処理したら true を返す（デフォルトは false）
  func handle(event: KeyboardEvent) -> Bool
}

extension LegacyView {
  public func handle(event: KeyboardEvent) -> Bool { false }
}
