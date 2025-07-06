import SwiftTUI
import Foundation

// 即座に終了するデバッグテスト
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