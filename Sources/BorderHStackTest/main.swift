// BorderHStackTest - HStack内のボーダーと背景色の動作確認
//
// 期待される挙動:
// 1. "Simple HStack with borders:"というラベル（シアン色）の下に:
//    - "A"、"B"、"C"がそれぞれ独立した枠線で囲まれて横並びで表示される
// 2. "HStack with backgrounds:"というラベル（シアン色）の下に:
//    - "1"（赤背景）、"2"（緑背景）、"3"（青背景）が横並びで表示される
// 3. "Both border and background:"というラベル（シアン色）の下に:
//    - "X"（黄背景、枠線付き）と"Y"（マゼンタ背景、枠線付き）が横並びで表示される
// 4. 各セクション間に空行が挿入される
// 5. ESCキーでプログラムが終了する
//
// 注意: HStack内でのボーダーと背景色の組み合わせをテストします
//       既知の制限により、隣接する要素の描画が重なる可能性があります
//
// 実行方法: swift run BorderHStackTest

import SwiftTUI

struct BorderHStackTestView: View {
    var body: some View {
        VStack {
            Text("Simple HStack with borders:")
                .foregroundColor(.cyan)
            
            HStack {
                Text("A")
                    .border()
                Text("B")
                    .border()
                Text("C")
                    .border()
            }
            
            Text("")
            Text("HStack with backgrounds:")
                .foregroundColor(.cyan)
            
            HStack {
                Text("1")
                    .background(.red)
                Text("2")
                    .background(.green)
                Text("3")
                    .background(.blue)
            }
            
            Text("")
            Text("Both border and background:")
                .foregroundColor(.cyan)
            
            HStack {
                Text("X")
                    .background(.yellow)
                    .border()
                Text("Y")
                    .background(.magenta)
                    .border()
            }
        }
    }
}

SwiftTUI.run {
    BorderHStackTestView()
}