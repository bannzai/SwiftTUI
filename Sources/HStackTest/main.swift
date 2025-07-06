// HStackTest - 基本的なHStack動作確認
//
// 期待される挙動:
// 1. "HStackTest starting..."というメッセージが出力される
// 2. HStackで3つのTextが横方向に配置される
// 3. "Left"、"Center"、"Right"が左から順に同じ行に表示される
// 4. 2秒後に"Exiting..."メッセージが出力される
// 5. プログラムが自動的に終了する
//
// 実行方法: swift run HStackTest

import SwiftTUI
import Foundation

print("HStackTest starting...")

// HStackのテスト
struct TestView: View {
    var body: some View {
        HStack {
            Text("Left")
            Text("Center")
            Text("Right")
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