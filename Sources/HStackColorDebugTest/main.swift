// HStackColorDebugTest - HStackの背景色レンダリング問題のデバッグ
//
// 期待される挙動:
// 1. "Individual texts with background:"というラベルが表示される
// 2. VStack内で個別に表示される:
//    - "A"（赤背景）
//    - "B"（緑背景）
//    - "C"（青背景）
// 3. 空行が挿入される
// 4. "HStack with backgrounds:"というラベルが表示される
// 5. HStack内で横並びに表示される:
//    - "A"（赤背景）、"B"（緑背景）、"C"（青背景）
// 6. ESCキーでプログラムが終了する
//
// 注意: VStack内とHStack内での背景色レンダリングの違いを確認し、
//       HStack内での背景色の重複問題をデバッグするためのテストです
//
// 実行方法: swift run HStackColorDebugTest

import SwiftTUI

struct HStackColorDebugView: View {
  var body: some View {
    VStack {
      Text("Individual texts with background:")
      Text("A").background(.red)
      Text("B").background(.green)
      Text("C").background(.blue)

      Text("")
      Text("HStack with backgrounds:")
      HStack {
        Text("A").background(.red)
        Text("B").background(.green)
        Text("C").background(.blue)
      }
    }
  }
}

SwiftTUI.run {
  HStackColorDebugView()
}
