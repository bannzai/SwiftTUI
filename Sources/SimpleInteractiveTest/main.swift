// SimpleInteractiveTest - シンプルなインタラクティブUIの動作確認
//
// 期待される挙動:
// 1. "Simple Interactive Test"と操作説明が表示される
// 2. タイトル "Simple Interactive Demo" が枠線付きで表示される
// 3. TextField（幅30）に名前を入力できる
// 4. 入力した名前に応じて挨拶メッセージが変わる（空の場合は"Hello, World!"）
// 5. 2つのボタンとカウンター表示が横並びで配置される:
//    - "Increment": カウンターを増加
//    - カウンター表示（青背景）
//    - "Reset": カウンターと名前をリセット
// 6. Tab/Shift+Tabでフィールド間を移動できる
// 7. Enter/Spaceでボタンをクリックできる
// 8. @Stateによる状態管理で、変更が即座にUIに反映される
// 9. Ctrl+CまたはESCでプログラムが終了する
//
// 実行方法: swift run SimpleInteractiveTest

import Foundation
import SwiftTUI

print("Simple Interactive Test")
print("Tab: Next field, Shift+Tab: Previous field")
print("Enter/Space: Press button, Ctrl+C: Exit\n")

struct SimpleInteractiveView: View {
  @State private var name = ""
  @State private var counter = 0

  var body: some View {
    VStack {
      Text("Simple Interactive Demo")
        .foregroundColor(.cyan)
        .padding(2)
        .border()

      TextField("Enter your name", text: $name)
        .frame(width: 30)

      Text("Hello, \(name.isEmpty ? "World" : name)!")
        .foregroundColor(.green)
        .padding()

      HStack {
        Button("Increment") {
          counter += 1
        }

        Text("Count: \(counter)")
          .padding()
          .background(.blue)

        Button("Reset") {
          counter = 0
          name = ""
        }
      }
    }
  }
}

SwiftTUI.run {
  SimpleInteractiveView()
}
