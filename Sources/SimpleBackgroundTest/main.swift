// SimpleBackgroundTest - 背景色modifierの基本的な動作確認
//
// 期待される挙動:
// 1. "Single background:"というラベルの後に、赤背景の"Hello"が表示される
// 2. "Multiple backgrounds:"というラベルの後に、以下が縦に並ぶ:
//    - "A"（赤背景）
//    - "B"（緑背景）
//    - "C"（青背景）
// 3. "In HStack:"というラベルの後に、横並びで表示される:
//    - "1"（赤背景）、"2"（緑背景）、"3"（青背景）
// 4. 各テキストの背景色が正しく適用される
// 5. ESCキーでプログラムが終了する
//
// 注意: HStack内での背景色レンダリングには既知の制限があります（CLAUDE.md参照）
//
// 実行方法: swift run SimpleBackgroundTest

import SwiftTUI

struct SimpleBackgroundTestView: View {
    var body: some View {
        VStack {
            Text("Single background:")
            Text("Hello")
                .background(.red)
            
            Text("")
            Text("Multiple backgrounds:")
            Text("A").background(.red)
            Text("B").background(.green)
            Text("C").background(.blue)
            
            Text("")
            Text("In HStack:")
            HStack {
                Text("1").background(.red)
                Text("2").background(.green)
                Text("3").background(.blue)
            }
        }
    }
}

SwiftTUI.run {
    SimpleBackgroundTestView()
}