// SimpleButtonActionTest - ボタンアクションと状態更新の動作確認
//
// 期待される挙動:
// 1. カウンターが0で表示される
// 2. Tabキーでボタンにフォーカスを移動（緑色の枠）
// 3. Space/Enterキーでボタンをクリック
// 4. カウンターがインクリメントされて画面が更新される
// 5. 'q'キーで終了
//
// 実行方法: swift run SimpleButtonActionTest

import SwiftTUI

struct SimpleButtonActionView: View {
  @State private var count = 0

  var body: some View {
    VStack {
      Text("Count: \(count)")
        .foregroundColor(.cyan)
        .padding()

      Button("Increment") {
        count += 1
        print("[Action] Count incremented to: \(count)")
      }

      Text("Tab: focus, Space/Enter: click, q: quit")
        .foregroundColor(.white)
    }
  }
}

// qキーで終了
GlobalKeyHandler.handler = { event in
  if event.key == .character("q") {
    CellRenderLoop.shutdown()
    return true
  }
  return false
}

SwiftTUI.run {
  SimpleButtonActionView()
}
