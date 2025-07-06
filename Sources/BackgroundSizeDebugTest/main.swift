import SwiftTUI
import Foundation

// HStack内でのサイズ計算をデバッグ
struct BackgroundSizeDebugView: View {
    var body: some View {
        HStack {
            Text("ABC").background(.red)
            Text("DEF").background(.green)
            Text("GHI").background(.blue)
        }
    }
}

// デバッグ用に短時間実行
DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
    // CellBufferの内容を詳細に出力
    print("\n=== Debug Complete ===")
    exit(0)
}

SwiftTUI.run {
    BackgroundSizeDebugView()
}