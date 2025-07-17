// KeyTestVerify - グローバルキーハンドラーの動作確認
//
// 期待される挙動:
// 1. "Key Test Verification"と"Testing global key handler..."が出力される
// 2. "Press 't' to test, 'q' to quit"という説明がシアン色で表示される
// 3. "Test count: 0"が緑色で表示される
// 4. 't'キーを押すとカウントが増加し、押したキーがコンソールに出力される
// 5. 'q'キーを押すとプログラムが終了する
// 6. 1秒後に自動的に't'キーがシミュレートされ、カウントが1増加する
// 7. 3秒後に"Auto-exiting..."と出力されてプログラムが自動終了する
//
// 注意: GlobalKeyHandlerによるキー入力処理とRenderLoop.scheduleRedraw()の
//       動作を確認するためのテストです
//
// 実行方法: swift run KeyTestVerify

import Foundation
import SwiftTUI

print("Key Test Verification")
print("Testing global key handler...")

// グローバルな状態
var testCount = 0

// グローバルキーハンドラーを設定
GlobalKeyHandler.handler = { event in
  print("Key pressed: \(event.key)")

  switch event.key {
  case .character("t"):
    testCount += 1
    print("Test count: \(testCount)")
    return true
  case .character("q"):
    print("Quitting...")
    RenderLoop.shutdown()
    return true
  default:
    return false
  }
}

struct TestView: View {
  var body: some View {
    VStack {
      Text("Press 't' to test, 'q' to quit")
        .foregroundColor(.cyan)

      Text("Test count: \(testCount)")
        .foregroundColor(.green)
    }
  }
}

// 3秒後に自動的に't'キーをシミュレート
DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
  print("\nSimulating 't' key press...")
  testCount += 1
  RenderLoop.scheduleRedraw()
}

// 5秒後に終了
DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
  print("Auto-exiting...")
  RenderLoop.shutdown()
}

SwiftTUI.run {
  TestView()
}
