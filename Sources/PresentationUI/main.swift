// ButtonFocusTest - ボタンフォーカス機能の動作確認
//
// 期待される挙動:
// 1. "Button Focus Test starting..."とキー操作説明が表示される
// 2. タイトル、カウンター、メッセージ、4つのボタンが表示される
// 3. Tabキーで次のボタンにフォーカスを移動できる
// 4. Shift+Tabキーで前のボタンにフォーカスを移動できる
// 5. Enter/Spaceキーでフォーカスされたボタンをクリックできる
// 6. ボタンクリックで対応するアクション（カウント増減、メッセージ切り替え、リセット）が実行される
// 7. 最後に実行されたアクションが表示される
// 8. 'q'キーでプログラムが終了する
//
// 実行方法: swift run ButtonFocusTest

import Foundation
import SwiftTUI

print("Button Focus Test starting...")
print("Tab/Shift+Tab: Move focus, Enter/Space: Press button, q: Quit")

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
