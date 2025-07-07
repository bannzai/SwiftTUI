// SimpleCellTest - セルベースレンダリングの基本的な動作確認
//
// 期待される挙動:
// 1. "Simple Cell Test"というタイトルが表示される
// 2. "RED"というテキストが赤い背景色で表示される
// 3. "BORDER"というテキストが枠線で囲まれて表示される
// 4. 全体がVStackで縦方向に配置される
// 5. ESCキーでプログラムが終了する
//
// 注意: セルベースレンダリングシステムでの背景色とボーダーの
//       基本的な動作を確認するためのテストです
//
// 実行方法: swift run SimpleCellTest

import SwiftTUI
struct SimpleCellTestView: View {
    var body: some View {
        VStack {
            Text("Simple Cell Test")
            
            // 単一の背景色
            Text("RED")
                .background(.red)
            
            // 単一のボーダー
            Text("BORDER")
                .border()
        }
    }
}

SwiftTUI.run {
    SimpleCellTestView()
}