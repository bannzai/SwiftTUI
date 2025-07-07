// TextCellRenderTest - Textビューのセルレンダリング動作確認
//
// 期待される挙動:
// 1. "Individual backgrounds:"というラベルが表示される
// 2. VStack内で以下が縦に並ぶ:
//    - "RED"（赤背景）
//    - "GREEN"（緑背景）
//    - "BLUE"（青背景）
// 3. 空行が挿入される
// 4. "HStack with backgrounds:"というラベルが表示される
// 5. HStack内で"A"（赤背景）、"B"（緑背景）、"C"（青背景）が横並びで表示される
// 6. ESCキーでプログラムが終了する
//
// 注意: VStack内とHStack内でのText背景色レンダリングの違いを確認します
//       HStack内では背景色の重複問題が発生する可能性があります
//
// 実行方法: swift run TextCellRenderTest

import SwiftTUI
struct TextCellRenderTestView: View {
    var body: some View {
        VStack {
            Text("Individual backgrounds:")
            Text("RED").background(.red)
            Text("GREEN").background(.green)
            Text("BLUE").background(.blue)
            
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
    TextCellRenderTestView()
}