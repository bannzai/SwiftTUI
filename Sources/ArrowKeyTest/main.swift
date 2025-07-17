// ArrowKeyTest - キー入力の動作確認（矢印キー含む）
//
// 期待される挙動:
// 1. タイトル "矢印キーテスト" が枠線付きで表示される
// 2. "矢印キーを押してください" という案内が表示される
// 3. 各種キーを押すと、デバッグ出力が表示される:
//    - ↑/↓/←/→: 矢印キーの検出
//    - ESC: エスケープキー
//    - Tab: タブキー
//    - Enter: エンターキー
//    - Space: スペースキー
//    - その他の文字: 文字キー
// 4. 押されたキーの情報が標準エラー出力に表示される
// 5. UIには "(ここに表示されます)" の部分は静的なままである
// 6. 10秒後に"Exiting..."メッセージが出力されて自動終了する
//
// 注意: GlobalKeyHandlerはfalseを返すため、他のハンドラーもキーを処理できる
//
// 実行方法: swift run ArrowKeyTest

import Foundation
import SwiftTUI

struct ArrowKeyTestView: View {
  var body: some View {
    VStack {
      Text("矢印キーテスト")
        .bold()
        .padding()
        .border()

      Text("矢印キーを押してください")
        .foregroundColor(.cyan)

      Text("最後に押されたキー:")
        .foregroundColor(.yellow)
        .padding()

      Text("(ここに表示されます)")
        .foregroundColor(.green)
        .padding()

      Text("ESC で終了")
        .foregroundColor(.white)
    }
  }
}

// グローバルキーハンドラーでデバッグ
GlobalKeyHandler.handler = { event in
  let keyName: String
  switch event.key {
  case .up:
    keyName = "↑ (Up)"
    print("DEBUG: Up arrow key pressed!")
  case .down:
    keyName = "↓ (Down)"
    print("DEBUG: Down arrow key pressed!")
  case .left:
    keyName = "← (Left)"
    print("DEBUG: Left arrow key pressed!")
  case .right:
    keyName = "→ (Right)"
    print("DEBUG: Right arrow key pressed!")
  case .escape:
    keyName = "ESC"
    print("DEBUG: ESC key pressed!")
  case .tab:
    keyName = "Tab"
    print("DEBUG: Tab key pressed!")
  case .enter:
    keyName = "Enter"
    print("DEBUG: Enter key pressed!")
  case .space:
    keyName = "Space"
    print("DEBUG: Space key pressed!")
  case .character(let c):
    keyName = "Char: \(c)"
    print("DEBUG: Character key pressed: \(c)")
  default:
    keyName = "Unknown"
    print("DEBUG: Unknown key pressed!")
  }

  // デバッグ用に標準エラーに出力
  fputs("Last key: \(keyName)\n", stderr)

  return false  // 他のハンドラーも処理できるようにfalseを返す
}

// 10秒後に自動終了
DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
  print("\nExiting...")
  RenderLoop.shutdown()
}

SwiftTUI.run {
  ArrowKeyTestView()
}
