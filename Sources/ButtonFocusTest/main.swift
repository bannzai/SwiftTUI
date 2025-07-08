// ButtonFocusTest - ボタンフォーカス機能の動作確認
//
// 期待される挙動:
// 1. "Button Focus Test starting..."とキー操作説明が表示される
// 2. タイトル、カウンター、メッセージ、4つのボタンが表示される
// 3. Tabキーで次のボタンにフォーカスを移動できる
// 4. Shift+Tabキーで前のボタンにフォーカスを移動できる
// 5. Enter/Spaceキーでフォーカスされたボタンをクリックできる
// 6. ボタンクリックで対応するアクション（カウント増減、メッセージ切り替え、リセット）が実行される
// 7. 最後に実行されたアクションが表示される
// 8. 'q'キーでプログラムが終了する
//
// 実行方法: swift run ButtonFocusTest

import SwiftTUI
import Foundation

print("Button Focus Test starting...")
print("Tab/Shift+Tab: Move focus, Enter/Space: Press button, q: Quit")

// ボタンとフォーカス機能のテスト
struct ButtonFocusView: View {
    @State private var count = 0
    @State private var message = "Hello"
    @State private var lastAction = "No action yet"
    
    var body: some View {
        VStack {
            Text("Button Focus Test")
                .foregroundColor(.cyan)
                .padding()
                .border()
            
            Text("Counter: \(count)")
                .foregroundColor(.green)
                .padding()
            
            Text("Message: \(message)")
                .foregroundColor(.yellow)
                .padding()
            
            // ボタンを縦に配置（HStackのレイアウト問題を回避）
            VStack(spacing: 1) {
                Button("Count++") { 
                    count += 1 
                    lastAction = "Incremented count"
                }
                
                Button("Count--") { 
                    count -= 1 
                    lastAction = "Decremented count"
                }
                
                Button("Toggle Message") { 
                    message = message == "Hello" ? "World" : "Hello"
                    lastAction = "Toggled message"
                }
                
                Button("Reset") {
                    count = 0
                    message = "Hello"
                    lastAction = "Reset all"
                }
            }
            
            Text("Last action: \(lastAction)")
                .foregroundColor(.white)
                .padding(.top)
        }
    }
}

// グローバルキーハンドラーでqキーで終了できるようにする
GlobalKeyHandler.handler = { event in
    switch event.key {
    case .character("q"):
        fputs("\nExiting...\n", stderr)
        CellRenderLoop.shutdown()
        return true
    default:
        return false
    }
}

// Viewを起動
SwiftTUI.run {
    ButtonFocusView()
}