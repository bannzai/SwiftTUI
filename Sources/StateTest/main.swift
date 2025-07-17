// StateTest - グローバル状態管理の動作確認
//
// 期待される挙動:
// 1. "State Test starting..."と操作説明が表示される
// 2. タイトル "State Test Demo" が枠線付きで表示される
// 3. カウンター値（初期値: 0）が緑色で表示される
// 4. メッセージ（初期値: "Hello"）が黄色で表示される
// 5. キー操作説明が白色で表示される
// 6. キー操作:
//    - 'u': カウンターを増加（リアルタイムで画面更新）
//    - 'd': カウンターを減少（リアルタイムで画面更新）
//    - 'm': メッセージを "Hello" ⇔ "World" 切り替え
//    - 'q': プログラムを終了
// 7. 状態変更時にRenderLoop.scheduleRedraw()で画面が再描画される
//
// 注意: @Stateの制限を回避するため、グローバル状態を使用しています
//
// 実行方法: swift run StateTest

import Foundation
import SwiftTUI

print("State Test starting...")
print("Press 'u' to increment, 'd' to decrement")
print("Press 'm' to change message, 'q' to quit")

// グローバルな状態を保持（@Stateの制限を回避）
class GlobalState {
  static var count = 0
  static var message = "Hello"
}

// Stateを使った動的UIのテスト
struct CounterView: View {
  var body: some View {
    VStack {
      Text("State Test Demo")
        .foregroundColor(.cyan)
        .padding()
        .border()

      Text("Counter: \(GlobalState.count)")
        .foregroundColor(.green)
        .padding()

      Text("Message: \(GlobalState.message)")
        .foregroundColor(.yellow)
        .padding()

      Text("u: increment, d: decrement")
        .foregroundColor(.white)

      Text("m: toggle message, q: quit")
        .foregroundColor(.white)
    }
  }
}

// グローバルキーハンドラーを設定
GlobalKeyHandler.handler = { event in
  switch event.key {
  case .character("u"):
    GlobalState.count += 1
    RenderLoop.scheduleRedraw()
    return true
  case .character("d"):
    GlobalState.count -= 1
    RenderLoop.scheduleRedraw()
    return true
  case .character("m"):
    GlobalState.message = GlobalState.message == "Hello" ? "World" : "Hello"
    RenderLoop.scheduleRedraw()
    return true
  case .character("q"):
    print("\nExiting...")
    RenderLoop.shutdown()
    return true
  default:
    return false
  }
}

// Viewを起動
SwiftTUI.run {
  CounterView()
}
