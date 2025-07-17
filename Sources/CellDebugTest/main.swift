// CellDebugTest - デバッグ出力を有効にしたセルレンダリングの動作確認
//
// 期待される挙動:
// 1. CellRenderLoop.DEBUGがtrueに設定され、詳細なデバッグ情報が出力される
// 2. "Debug Test"というタイトルが表示される
// 3. HStack内に"A"（赤背景）、"B"（緑背景）、"C"（青背景）が横並びで表示される
// 4. デバッグ出力により、セルレンダリングの内部処理が確認できる:
//    - レイアウト計算の詳細
//    - セルバッファへの書き込み処理
//    - 描画位置の計算
// 5. ESCキーでプログラムが終了する
//
// 注意: 開発者向けのデバッグテストで、セルレンダリングシステムの
//       内部動作を可視化します
//
// 実行方法: swift run CellDebugTest

import SwiftTUI

CellRenderLoop.DEBUG = true

struct CellDebugTestView: View {
  var body: some View {
    VStack {
      Text("Debug Test")

      HStack {
        Text("A").background(.red)
        Text("B").background(.green)
        Text("C").background(.blue)
      }
    }
  }
}

SwiftTUI.run {
  CellDebugTestView()
}
