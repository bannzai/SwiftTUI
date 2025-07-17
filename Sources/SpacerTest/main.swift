// SpacerTest - Spacerコンポーネントの動作確認
//
// 期待される挙動:
// 1. "SpacerTest starting..."というメッセージが出力される
// 2. HStack内でSpacerが使用される
// 3. "Left"というテキストが左端に表示される
// 4. "Right"というテキストが右端に表示される
// 5. Spacerにより、2つのテキスト間のスペースが自動的に広がる
// 6. 結果として、"Left"と"Right"がコンテナの両端に配置される
// 7. 2秒後に"Exiting..."メッセージが出力される
// 8. プログラムが自動的に終了する
//
// 実行方法: swift run SpacerTest

import Foundation
import SwiftTUI

print("SpacerTest starting...")

// Spacerのテスト
struct TestView: View {
  var body: some View {
    HStack {
      Text("Left")
      Spacer()
      Text("Right")
    }
  }
}

// 短時間で終了
DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
  print("Exiting...")
  RenderLoop.shutdown()
  exit(0)
}

SwiftTUI.run(TestView())
