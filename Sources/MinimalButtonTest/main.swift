// MinimalButtonTest - 最小限のボタンフォーカステスト
//
// 期待される挙動:
// 1. 単一のボタンが表示される
// 2. 初回描画時にボタンがFocusManagerに登録される
// 3. 各種デバッグログが表示される
// 4. ESCキーでプログラムが終了する
//
// 実行方法: swift run MinimalButtonTest

import Foundation
import SwiftTUI
@_spi(ViewRendererSPI) import SwiftTUI

print("=== MinimalButtonTest Starting ===", to: &stdError)

// stderr出力用のヘルパー
var stdError = FileHandle.standardError

extension FileHandle: TextOutputStream {
  public func write(_ string: String) {
    self.write(Data(string.utf8))
  }
}

struct MinimalView: View {
  var body: some View {
    VStack {
      Text("Minimal Button Test")

      Button("Test Button") {
        print("Button clicked!", to: &stdError)
      }

      Text("Press Tab to test focus")
    }
  }
}

// より詳細なグローバルハンドラー
GlobalKeyHandler.handler = { event in
  print("[MinimalTest] GlobalKeyHandler received: \(event.key)", to: &stdError)

  switch event.key {
  case .tab:
    print("[MinimalTest] Tab key - letting FocusManager handle it", to: &stdError)
    return false
  case .escape:
    print("[MinimalTest] ESC key - exiting", to: &stdError)
    CellRenderLoop.shutdown()
    return true
  default:
    return false
  }
}

// 起動時にFocusManagerの状態を確認
DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
  print("\n=== FocusManager State Check ===", to: &stdError)
  // FocusManagerはinternalなので直接アクセスできない
  print("=== End State Check ===\n", to: &stdError)
}

print("Starting SwiftTUI.run...", to: &stdError)
SwiftTUI.run {
  MinimalView()
}
