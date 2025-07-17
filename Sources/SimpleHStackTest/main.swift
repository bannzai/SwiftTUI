// SimpleHStackTest - HStackの最小限の動作確認
//
// 期待される挙動:
// 1. HStack内に3つのテキストが横並びで配置される
// 2. "A"（赤背景）、"B"（緑背景）、"C"（青背景）の順で表示される
// 3. 各テキストが隣接して表示される
// 4. ESCキーでプログラムが終了する
//
// 注意: HStack内での背景色レンダリングには既知の制限があります
//       後の要素が前の要素の背景色を上書きする可能性があります（CLAUDE.md参照）
//
// 実行方法: swift run SimpleHStackTest

import SwiftTUI

struct SimpleHStackTestView: View {
  var body: some View {
    HStack {
      Text("A").background(.red)
      Text("B").background(.green)
      Text("C").background(.blue)
    }
  }
}

SwiftTUI.run {
  SimpleHStackTestView()
}
