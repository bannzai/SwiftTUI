// QuickDebugTest - 短時間で自動終了するデバッグテスト
//
// 期待される挙動:
// 1. "=== Quick Debug Test ==="が出力される
// 2. HStack内に"A"（赤背景）、"B"（緑背景）、"C"（青背景）が横並びで表示される
// 3. 1秒後に"=== Forcing exit ==="が出力される
// 4. プログラムが強制終了される（exit(0)）
//
// 注意: HStackの背景色レンダリングを短時間で確認するための自動テストです
//       非同期処理により1秒後に強制終了します
//
// 実行方法: swift run QuickDebugTest

import SwiftTUI
import Foundation

print("=== Quick Debug Test ===")

struct QuickDebugView: View {
    var body: some View {
        HStack {
            Text("A").background(.red)
            Text("B").background(.green)
            Text("C").background(.blue)
        }
    }
}

// 非同期で実行してすぐ終了
DispatchQueue.global().async {
    sleep(1)
    print("=== Forcing exit ===")
    exit(0)
}

SwiftTUI.run {
    QuickDebugView()
}