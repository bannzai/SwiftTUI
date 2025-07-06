import SwiftTUI
import Foundation

// 詳細なデバッグ出力を含むHStackテスト
print("=== Verbose HStack Test Start ===")

struct VerboseHStackTestView: View {
    var body: some View {
        HStack {
            Text("A").background(.red)
            Text("B").background(.green)
            Text("C").background(.blue)
        }
    }
}

// グローバルフラグでデバッグを有効化
CellRenderLoop.DEBUG = true

// 実行
SwiftTUI.run {
    VerboseHStackTestView()
}

// 短時間で強制終了
DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
    print("\n=== Test Complete ===")
    exit(0)
}