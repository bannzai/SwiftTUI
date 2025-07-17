// DirectionalPaddingTest - 方向指定パディングの動作確認
//
// 期待される挙動:
// 1. タイトル "Directional Padding Test" が下部に3単位のパディング付きで表示される
// 2. グループ1 - 個別方向のパディング:
//    - "Top padding: 2": 上部のみ2単位のパディング（青背景）
//    - "Bottom padding: 2": 下部のみ2単位のパディング（緑背景）
//    - "Leading padding: 3": 左側のみ3単位のパディング（黄背景）
//    - "Trailing padding: 3": 右側のみ3単位のパディング（赤背景）
//    - 各要素は枠線で囲まれ、パディングの効果が視覚的に確認できる
// 3. グループ2 - Edge Setのパディング:
//    - "Horizontal padding: 2": 左右に2単位のパディング（シアン背景）
//    - "Vertical padding: 2": 上下に2単位のパディング（マゼンタ背景）
//    - "All padding: 1": 全方向に1単位のパディング（白背景）
// 4. 全体が枠線で囲まれ、各パディングの効果が明確に表示される
// 5. ESCキーでプログラムが終了する
//
// 実行方法: swift run DirectionalPaddingTest

import SwiftTUI

struct DirectionalPaddingTestView: View {
  var body: some View {
    VStack(spacing: 2) {
      Text("Directional Padding Test")
        .bold()
        .padding(Edge.bottom, 3)

      // Group 1: Individual directions
      VStack(spacing: 1) {
        Text("Top padding: 2")
          .padding(Edge.top, 2)
          .background(.blue)
          .border()

        Text("Bottom padding: 2")
          .padding(Edge.bottom, 2)
          .background(.green)
          .border()

        Text("Leading padding: 3")
          .padding(Edge.leading, 3)
          .background(.yellow)
          .border()

        Text("Trailing padding: 3")
          .padding(Edge.trailing, 3)
          .background(.red)
          .border()
      }

      // Group 2: Edge sets
      VStack(spacing: 1) {
        Text("Horizontal padding: 2")
          .padding(.horizontal, 2)
          .background(.cyan)
          .border()

        Text("Vertical padding: 2")
          .padding(.vertical, 2)
          .background(.magenta)
          .border()

        Text("All padding: 1")
          .padding()
          .background(.white)
          .border()
      }
    }
    .padding()
    .border()
  }
}

SwiftTUI.run {
  DirectionalPaddingTestView()
}
