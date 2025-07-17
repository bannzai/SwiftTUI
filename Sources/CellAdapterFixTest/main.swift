// CellAdapterFixTest - CellLayoutAdapterの修正検証テスト
//
// このテストは以下を検証します：
// 1. CellLayoutAdapterの修正後の動作
// 2. HStack内で連続する要素の背景色レンダリング
// 3. 各要素の背景色が正しく分離されて表示されるか
//
// 期待される動作：
// - "A" が赤背景、"B" が緑背景、"C" が青背景で表示される
// - 各背景色が他の要素に影響を与えずに正しく表示される
// - 隐られた内容や重なりが発生しない
//
// 実行方法：
// swift run CellAdapterFixTest

import SwiftTUI

struct CellAdapterFixTestView: View {
  var body: some View {
    HStack {
      Text("A").background(.red)
      Text("B").background(.green)
      Text("C").background(.blue)
    }
  }
}

SwiftTUI.run {
  CellAdapterFixTestView()
}
