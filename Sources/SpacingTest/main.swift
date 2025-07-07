// SpacingTest - スタックのspacing引数の動作確認
//
// 期待される挙動:
// 1. 外側のVStackにはデフォルトspacing（0）が適用される
// 2. 最初のセクション: デフォルトスペーシングの説明テキスト
// 3. 中央のVStack（spacing: 2）:
//    - 3つのアイテムが2単位の間隔で縦に配置される
//    - Item 1（青背景）、Item 2（緑背景）、Item 3（黄背景）
//    - 枠線で囲まれている
// 4. HStackの説明テキスト
// 5. 下部のHStack（spacing: 3）:
//    - 3つのアイテムが3単位の間隔で横に配置される
//    - A（赤背景）、B（シアン背景）、C（マゼンタ背景）
//    - 枠線で囲まれている
// 6. spacing引数により、各要素間の間隔が調整される
// 7. ESCキーでプログラムが終了する
//
// 実行方法: swift run SpacingTest

import SwiftTUI

struct SpacingTestView: View {
    var body: some View {
        VStack {
            Text("VStack with default spacing (0)")
                .padding()
                .border()
            
            VStack(spacing: 2) {
                Text("Item 1")
                    .padding()
                    .background(.blue)
                
                Text("Item 2")
                    .padding()
                    .background(.green)
                
                Text("Item 3")
                    .padding()
                    .background(.yellow)
            }
            .padding()
            .border()
            
            Text("HStack with spacing: 3")
                .padding()
            
            HStack(spacing: 3) {
                Text("A")
                    .padding()
                    .background(.red)
                
                Text("B")
                    .padding()
                    .background(.cyan)
                
                Text("C")
                    .padding()
                    .background(.magenta)
            }
            .padding()
            .border()
        }
    }
}

SwiftTUI.run {
    SpacingTestView()
}