import SwiftTUI

struct BorderDebugTest: View {
  var body: some View {
    VStack(spacing: 2) {
      Text("Hakata.swift 2025-07-18")
        .border()

      Text("おしまい \(^o^)/")
        .border()

      Text("Hello World")
        .border()

      Text("こんにちは世界")
        .border()

      Text("ABC 日本語 123")
        .border()
    }
  }
}

SwiftTUI.run(BorderDebugTest()) { event in
  switch event.key {
  case .character("q"):
    return false
  default:
    return true
  }
}
