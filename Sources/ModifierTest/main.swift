// ModifierTest - ViewModifierチェーンの動作確認
//
// 期待される挙動:
// 1. "ModifierTest starting..."というメッセージが出力される
// 2. "Combined Modifiers: padding + border"というテキストが表示される
// 3. テキストには2単位のパディングが適用される
// 4. パディングの外側に枠線が描画される
// 5. モディファイアの適用順序が正しく反映される（先にpadding、次にborder）
// 6. 3秒後に"Exiting..."メッセージが出力される
// 7. プログラムが自動的に終了する
//
// 実行方法: swift run ModifierTest

import Foundation
import SwiftTUI

print("ModifierTest starting...")

struct ModifierTestView: View {
  var body: some View {
    // 複数のModifierをチェイン
    Text("Combined Modifiers: padding + border")
      .padding(2)
      .border()
  }
}

// 短時間で終了
DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
  print("Exiting...")
  RenderLoop.shutdown()
  exit(0)
}

SwiftTUI.run(ModifierTestView())
