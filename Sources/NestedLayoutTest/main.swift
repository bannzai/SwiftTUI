// NestedLayoutTest - ネストされたレイアウトの動作確認
//
// 期待される挙動:
// 1. "NestedLayoutTest starting..."というメッセージが出力される
// 2. 外側のVStackに3つの要素が縦に配置される:
//    - "Title": 上部
//    - HStack: 中央（3つの要素を含む）
//    - "Footer": 下部
// 3. 中央のHStackには3つの要素が横に配置される:
//    - "Left": 左側
//    - VStack: 中央（"Top"と"Bottom"を縦に配置）
//    - "Right": 右側
// 4. ネストされたレイアウトが正しく機能し、各要素が適切な位置に表示される
// 5. 2秒後に"Exiting..."メッセージが出力される
// 6. プログラムが自動的に終了する
//
// 実行方法: swift run NestedLayoutTest

import Foundation
import SwiftTUI

print("NestedLayoutTest starting...")

// ネストされたレイアウトのテスト
struct TestView: View {
  var body: some View {
    VStack {
      Text("Title")
      HStack {
        Text("Left")
        VStack {
          Text("Top")
          Text("Bottom")
        }
        Text("Right")
      }
      Text("Footer")
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
