// SimpleForEachTest - ForEachRangeの基本的な動作確認
//
// 期待される挙動:
// 1. "ForEach Test"というタイトルが太字で表示される
// 2. ForEachRangeにより0から2までのインデックスで繰り返し処理される
// 3. "Item 0"、"Item 1"、"Item 2"の3つのアイテムが縦に並んで表示される
// 4. 全体がVStackで縦方向に配置される
// 5. ESCキーでプログラムが終了する
//
// 注意: ForEachRangeはRange<Int>を使用した最も基本的なForEach実装です
//
// 実行方法: swift run SimpleForEachTest

import SwiftTUI

struct SimpleForEachView: View {
    var body: some View {
        VStack {
            Text("ForEach Test")
                .bold()
            
            ForEachRange(0..<3) { i in
                Text("Item \(i)")
            }
        }
    }
}

SwiftTUI.run {
    SimpleForEachView()
}