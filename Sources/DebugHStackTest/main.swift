// DebugHStackTest - HStack内の複数ボタンレンダリングの動作確認
//
// 期待される挙動:
// 1. "Debug HStack Test"と"Testing HStack with Buttons rendering..."が出力される
// 2. "Testing HStack with multiple buttons"というメッセージがシアン色で表示される
// 3. HStack内に3つのボタンが横並びで表示される:
//    - "Btn1"、"Btn2"、"Btn3"
// 4. "Should see 3 buttons above"というメッセージが黄色で表示される
// 5. 3秒後に"Exiting..."と出力されてプログラムが自動終了する
// 6. ボタンをクリックすると対応するメッセージがコンソールに出力される
//
// 注意: HStack内でのボタンコンポーネントのレンダリングを確認するデバッグテストです
//
// 実行方法: swift run DebugHStackTest

import SwiftTUI
import Foundation

print("Debug HStack Test")
print("Testing HStack with Buttons rendering...")

struct DebugView: View {
    var body: some View {
        VStack {
            Text("Testing HStack with multiple buttons")
                .foregroundColor(.cyan)
            
            HStack {
                Button("Btn1") {
                    print("Button1 pressed")
                }
                
                Button("Btn2") {
                    print("Button2 pressed")
                }
                
                Button("Btn3") {
                    print("Button3 pressed")
                }
            }
            
            Text("Should see 3 buttons above")
                .foregroundColor(.yellow)
        }
    }
}

// Auto exit after 3 seconds
DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
    print("Exiting...")
    RenderLoop.shutdown()
}

SwiftTUI.run {
    DebugView()
}