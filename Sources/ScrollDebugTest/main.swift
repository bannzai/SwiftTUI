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