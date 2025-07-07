// QuickHStackTest - HStackの自動テスト（0.1秒で終了）
//
// 期待される挙動:
// 1. HStack内に3つのテキストが横並びで配置される
// 2. "A"（赤背景）、"B"（緑背景）、"C"（青背景）の順で表示される
// 3. 0.1秒後に自動的にプログラムが終了する
//
// 注意: HStackの基本的な動作を短時間で確認するための自動テストです
//       HStack内での背景色レンダリングには既知の制限があります（CLAUDE.md参照）
//
// 実行方法: swift run QuickHStackTest

import SwiftTUI
import Foundation
struct QuickHStackTestView: View {
    var body: some View {
        HStack {
            Text("A").background(.red)
            Text("B").background(.green)
            Text("C").background(.blue)
        }
    }
}

// 短時間で終了
DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
    exit(0)
}

SwiftTUI.run {
    QuickHStackTestView()
}