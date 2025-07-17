// SimplePaddingTest - ViewModifierの基本動作確認
//
// 期待される挙動:
// 1. "ViewModifier Test starting..."というメッセージが出力される
// 2. 4つのテキストが縦に並んで表示される:
//    - "With padding and border": 2単位のパディングと枠線付き
//    - "Red text": 赤色のテキスト
//    - "Blue background": 青色の背景
//    - "Green text on yellow bg": 緑色のテキストに黄色の背景、パディング付き
// 3. 各モディファイア（padding、border、foregroundColor、background）が正しく適用される
// 4. モディファイアのチェーンが正しく動作する
// 5. 2秒後に"Exiting..."メッセージが出力される
// 6. プログラムが自動的に終了する
//
// 実行方法: swift run SimplePaddingTest

import Foundation
import SwiftTUI

print("ViewModifier Test starting...")

struct TestView: View {
  var body: some View {
    VStack {
      Text("With padding and border")
        .padding(2)
        .border()

      Text("Red text")
        .foregroundColor(.red)

      Text("Blue background")
        .background(.blue)

      Text("Green text on yellow bg")
        .foregroundColor(.green)
        .background(.yellow)
        .padding()
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
