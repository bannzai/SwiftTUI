// TestExample - シンプルなテキスト表示の動作確認
//
// 期待される挙動:
// 1. "TestExample starting..."というメッセージが出力される
// 2. "Creating view..."というメッセージが出力される
// 3. "Starting SwiftTUI.run..."というメッセージが出力される
// 4. "Simple Text Test"というテキストが画面に表示される
// 5. ESCキーでプログラムが終了する
//
// 注意: 最も基本的なテストケースで、Text Viewが正しくレンダリングされることを確認します
//
// 実行方法: swift run TestExample

import Foundation
import SwiftTUI

print("TestExample starting...")

// シンプルなテキストのみ
struct SimpleTextView: View {
  var body: some View {
    Text("Simple Text Test")
  }
}

print("Creating view...")
let view = SimpleTextView()

print("Starting SwiftTUI.run...")
SwiftTUI.run(view)
