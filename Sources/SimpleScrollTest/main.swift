// SimpleScrollTest - 基本的なScrollViewの動作確認
//
// 期待される挙動:
// 1. "シンプルなScrollViewテスト"というタイトルが太字で表示される
// 2. "↑↓ キーでスクロール"という操作説明がシアン色で表示される
// 3. ScrollView内に5つのアイテムが配置される（1番目〜5番目）
// 4. ScrollViewは3行分の高さに制限され、枠線で囲まれる
// 5. 上下矢印キーでスクロール操作ができる
// 6. 各アイテムは異なる色（緑、黄、シアン、マゼンタ、青）で表示される
// 7. "ESC で終了"というメッセージが白色で表示される
// 8. ESCキーでプログラムが終了する
//
// 注意: ScrollViewの基本的なスクロール機能を確認するためのテストです
//
// 実行方法: swift run SimpleScrollTest

import SwiftTUI
import Foundation

struct SimpleScrollTestView: View {
    var body: some View {
        VStack {
            Text("シンプルなScrollViewテスト")
                .bold()
                .padding()
            
            Text("↑↓ キーでスクロール")
                .foregroundColor(.cyan)
            
            ScrollView {
                VStack {
                    Text("1番目").foregroundColor(.green).padding()
                    Text("2番目").foregroundColor(.yellow).padding()
                    Text("3番目").foregroundColor(.cyan).padding()
                    Text("4番目").foregroundColor(.magenta).padding()
                    Text("5番目").foregroundColor(.blue).padding()
                }
            }
            .frame(height: 3)  // 3行分の高さ
            .border()
            
            Text("ESC で終了")
                .foregroundColor(.white)
        }
    }
}

// 手動でテストするため、自動終了を無効化
// DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
//     print("\nExiting...")
//     RenderLoop.shutdown()
// }

SwiftTUI.run {
    SimpleScrollTestView()
}