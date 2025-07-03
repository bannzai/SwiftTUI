public protocol View {
  func render(into buffer: inout [String])

  /// キーイベントを処理したら true を返す（デフォルトは false）
  func handle(event: KeyboardEvent) -> Bool
}

public extension View {
  func handle(event: KeyboardEvent) -> Bool { false }
}
