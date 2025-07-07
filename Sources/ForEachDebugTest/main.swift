// ForEachDebugTest - ForEach コンポーネントのレンダリングテスト
//
// このテストは以下を検証します：
// 1. HStack内でForEachを使用した要素のレンダリング
// 2. ForEachで生成された要素に対するborderの適用
// 3. ForEachで生成された要素に対する条件付き背景色の適用
//
// 期待される動作：
// - 最初のHStackで3つのボーダー付きテキストが横並びで表示される
// - 2番目のHStackで偶数インデックスは緑、奇数インデックスは青の背景色で表示される
//
// 実行方法：
// swift run ForEachDebugTest

import SwiftTUI

struct ForEachDebugView: View {
    var body: some View {
        VStack {
            Text("HStack with ForEach:")
                .foregroundColor(.cyan)
            
            HStack {
                ForEachRange(0..<3) { i in
                    Text("[\(i)]")
                        .border()
                }
            }
            
            Text("ForEach with bg color:")
                .foregroundColor(.cyan)
            
            HStack {
                ForEachRange(0..<3) { i in
                    Text("\(i)")
                        .background(i % 2 == 0 ? .green : .blue)
                }
            }
        }
    }
}

SwiftTUI.run {
    ForEachDebugView()
}