// ScrollDebugTest - ScrollViewのフォーカス管理とスクロール動作のデバッグ
//
// 期待される挙動:
// 1. "ScrollView デバッグテスト"というタイトルが枠線付きで表示される
// 2. "ステータス: 初期状態"がシアン色で表示される（@State変数）
// 3. "↑↓ キーでスクロール, Tab でフォーカス移動"という説明が黄色で表示される
// 4. ScrollView内に8つの項目が表示される（項目1〜8、各色付き）
// 5. ScrollViewは5行分の高さに制限され、枠線で囲まれる
// 6. 上下矢印キーでScrollView内をスクロールできる
// 7. TabキーでScrollViewとボタン間のフォーカスを移動できる
// 8. "テストボタン"をクリックして動作確認ができる
// 9. "ESC で終了"というメッセージが白色で表示される
// 10. 10秒後に自動的にプログラムが終了する
// 11. ESCキーでも即座に終了できる
//
// 注意: ScrollViewとButton間のフォーカス管理をデバッグするためのテストです
//
// 実行方法: swift run ScrollDebugTest

import SwiftTUI
import Foundation

struct ScrollDebugView: View {
    @State private var scrollStatus = "初期状態"
    
    var body: some View {
        VStack {
            VStack {
                Text("ScrollView デバッグテスト")
                    .bold()
                    .padding()
                    .border()
                
                Text("ステータス: \(scrollStatus)")
                    .foregroundColor(.cyan)
                    .padding()
                
                Text("↑↓ キーでスクロール, Tab でフォーカス移動")
                    .foregroundColor(.yellow)
            }
            
            VStack {
                // フォーカス可能なScrollView
                ScrollView {
                    VStack(spacing: 1) {
                        VStack {
                            Text("1. 項目1").foregroundColor(.green).padding()
                            Text("2. 項目2").foregroundColor(.yellow).padding()
                            Text("3. 項目3").foregroundColor(.cyan).padding()
                            Text("4. 項目4").foregroundColor(.magenta).padding()
                        }
                        VStack {
                            Text("5. 項目5").foregroundColor(.blue).padding()
                            Text("6. 項目6").foregroundColor(.red).padding()
                            Text("7. 項目7").foregroundColor(.white).padding()
                            Text("8. 項目8").foregroundColor(.green).padding()
                        }
                    }
                }
                .frame(height: 5)  // 5行分の高さ
                .border()
                .padding()
                
                // フォーカステスト用のボタン
                Button("テストボタン") {
                    // ボタンが押されたことを確認
                }
                
                Text("ESC で終了")
                    .foregroundColor(.white)
            }
        }
    }
}

// 10秒後に自動終了
DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
    print("\nExiting...")
    RenderLoop.shutdown()
}

SwiftTUI.run {
    ScrollDebugView()
}