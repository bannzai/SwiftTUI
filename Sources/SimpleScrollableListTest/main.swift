// SimpleScrollableListTest - ScrollViewの基本的な使い方の説明と動作確認
//
// 期待される挙動:
// 1. "SwiftTUIでのスクロールの仕組み"というタイトルが枠線付きで表示される
// 2. "↑↓ キーでスクロール"という操作説明がシアン色で表示される
// 3. ScrollView内に10個の説明テキストが表示される（1〜10の番号付き）
// 4. 各テキストは異なる色で表示される（緑、黄、シアン、マゼンタ、青、赤、白）
// 5. ScrollViewは8行分の高さに制限され、枠線で囲まれる
// 6. 上下矢印キーでスクロール操作ができる（10行中8行が表示）
// 7. "ESC で終了"というメッセージが白色で表示される
// 8. 10秒後に自動的にプログラムが終了する
// 9. ESCキーでも即座に終了できる
//
// 注意: SwiftTUIにおけるScrollViewの使い方を説明する教育的なテストです
//
// 実行方法: swift run SimpleScrollableListTest

import SwiftTUI
import Foundation

struct SimpleScrollableListView: View {
    var body: some View {
        VStack {
            Text("SwiftTUIでのスクロールの仕組み")
                .bold()
                .padding()
                .border()
            
            Text("↑↓ キーでスクロール")
                .foregroundColor(.cyan)
                .padding()
            
            // ScrollViewで高さを制限して、スクロール可能にする
            ScrollView {
                VStack(spacing: 2) {
                    VStack {
                        Text("1. SwiftTUIのListは")
                            .foregroundColor(.green)
                            .padding()
                        
                        Text("2. 自動スクロールしない")
                            .foregroundColor(.yellow)
                            .padding()
                        
                        Text("3. ScrollViewで囲む必要がある")
                            .foregroundColor(.cyan)
                            .padding()
                        
                        Text("4. frameで高さを指定")
                            .foregroundColor(.magenta)
                            .padding()
                        
                        Text("5. すると表示領域が制限される")
                            .foregroundColor(.blue)
                            .padding()
                    }
                    
                    VStack {
                        Text("6. 矢印キーでスクロール可能に")
                            .foregroundColor(.red)
                            .padding()
                        
                        Text("7. これがSwiftUIとの違い")
                            .foregroundColor(.white)
                            .padding()
                        
                        Text("8. SwiftUIのListは自動スクロール")
                            .foregroundColor(.green)
                            .padding()
                        
                        Text("9. SwiftTUIは明示的なScrollView")
                            .foregroundColor(.yellow)
                            .padding()
                        
                        Text("10. InkのReactパターンに近い")
                            .foregroundColor(.cyan)
                            .padding()
                    }
                }
            }
            .frame(height: 8)  // 8行分の高さ（コンテンツは10行）
            .border()
            .padding()
            
            Text("ESC で終了")
                .foregroundColor(.white)
        }
    }
}

// 10秒後に自動終了
DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
    print("\nExiting...")
    RenderLoop.shutdown()
}

SwiftTUI.run {
    SimpleScrollableListView()
}