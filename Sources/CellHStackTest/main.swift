// CellHStackTest - セルベースレンダリングを使用したHStackの動作確認
//
// 期待される挙動:
// 1. "Cell-based HStack Test"というタイトルがシアン色の太字で表示される
// 2. "1. Backgrounds in HStack (Fixed!):"の下に:
//    - "AAA"（赤背景）、"BBB"（緑背景）、"CCC"（青背景）が横並びで表示される
//    - 各背景色が正しく独立して表示される（CellFlexStack使用）
// 3. "2. Borders in HStack (Fixed!):"の下に:
//    - "X"、"Y"、"Z"がそれぞれ独立した枠線で囲まれて表示される
// 4. "3. Complex example:"の下に:
//    - "Hello"（白文字、赤背景、枠線付き）と"World"（黒文字、黄背景、枠線付き）が横並びで表示される
// 5. ESCキーでプログラムが終了する
//
// 注意: セルベースレンダリングシステムにより、HStack内の背景色とボーダーの
//       重複問題が解決されていることを確認するテストです
//
// 実行方法: swift run CellHStackTest

import SwiftTUI

struct CellHStackTestView: View {
  var body: some View {
    VStack {
      Text("Cell-based HStack Test")
        .foregroundColor(.cyan)
        .bold()

      Text("")
      Text("1. Backgrounds in HStack (Fixed!):")

      // このHStackは内部でCellFlexStackを使用
      HStack {
        Text("AAA")
          .background(.red)
        Text("BBB")
          .background(.green)
        Text("CCC")
          .background(.blue)
      }

      Text("")
      Text("2. Borders in HStack (Fixed!):")

      HStack {
        Text("X")
          .border()
        Text("Y")
          .border()
        Text("Z")
          .border()
      }

      Text("")
      Text("3. Complex example:")

      HStack {
        Text("Hello")
          .foregroundColor(.white)
          .background(.red)
          .border()

        Text("World")
          .foregroundColor(.black)
          .background(.yellow)
          .border()
      }
    }
  }
}

// 通常のSwiftTUI実行（内部でセルベースレンダリングが使用される）
SwiftTUI.run {
  CellHStackTestView()
}
