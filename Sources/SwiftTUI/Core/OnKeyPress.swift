struct OnKeyPress<Content: View>: View {
  let keys: [KeyboardKey]
  let action: () -> Void
  let content: Content

  func render(into buffer: inout [String]) {
    content.render(into: &buffer)
  }

  func handle(event: KeyboardEvent) -> Bool {
    if keys.contains(event.key) {
      action()
      return true
    }
    return content.handle(event: event)
  }
}

public extension View {
  /// 例: `.onKeyPress(.character("i")) { … }`
  func onKeyPress(_ keys: KeyboardKey...,
                  perform action: @escaping () -> Void) -> some View {
    OnKeyPress(keys: keys, action: action, content: self)
  }
}
