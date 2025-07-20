import Foundation
import SwiftTUI

// ボタンとフォーカス機能のテスト
struct PresentationUI: View {
  var body: some View {
    VStack {
      Text("Hakata.swift 2025-07-18")
        .padding(2)
        .border()

      Spacer().frame(height: 5)

      Text("おしまい \\(^o^)/")
        .padding(2)
        .border()
    }
  }
}

// グローバルキーハンドラーでqキーで終了できるようにする
GlobalKeyHandler.handler = { event in
  switch event.key {
  case .character("q"):
    print("\nExiting...")
    CellRenderLoop.shutdown()
    return true
  default:
    return false
  }
}

// Viewを起動
SwiftTUI.run {
  PresentationUI()
}
