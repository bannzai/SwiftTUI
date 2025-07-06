// SimpleVStackTest - 最小限のVStack動作確認
//
// 期待される挙動:
// 1. "SimpleVStackTest starting..."というメッセージが出力される
// 2. VStackで2つのTextが縦方向に配置される
// 3. "Line 1"と"Line 2"が上から順に表示される
// 4. 2秒後に"Exiting..."メッセージが出力される
// 5. プログラムが自動的に終了する
//
// 実行方法: swift run SimpleVStackTest

import SwiftTUI
import Foundation

print("SimpleVStackTest starting...")

// 最小限のVStackテスト
struct TestView: View {
    var body: some View {
        VStack {
            Text("Line 1")
            Text("Line 2")
        }
    }
}

// 短時間で終了
DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
    print("Exiting...")
    RenderLoop.shutdown()
    exit(0)
}

SwiftTUI.run(TestView())