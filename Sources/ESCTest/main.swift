// ESCTest - ESCキーによる終了機能の動作確認
//
// 期待される挙動:
// 1. "ESCキーテスト"というタイトルが太字で表示される
// 2. "ESC キーを押して終了"というメッセージがシアン色で表示される
// 3. ESCキーを押すとプログラムが正常に終了する
// 4. 全体がVStackで縦方向に配置される
//
// 注意: SwiftTUIの基本的な終了機能を確認するためのテストです
//
// 実行方法: swift run ESCTest

import SwiftTUI

struct ESCTestView: View {
  var body: some View {
    VStack {
      Text("ESCキーテスト")
        .bold()
        .padding()

      Text("ESC キーを押して終了")
        .foregroundColor(.cyan)
    }
  }
}

SwiftTUI.run {
  ESCTestView()
}
