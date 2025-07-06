import SwiftTUI

// デバッグ出力を有効化
CellRenderLoop.DEBUG = true

struct HStackBackgroundDebugView: View {
    var body: some View {
        VStack {
            Text("Debug HStack Background Issue")
            HStack {
                Text("A").background(.red)
                Text("B").background(.green)
                Text("C").background(.blue)
            }
        }
    }
}

// 実行時にプロセスが終了しないよう、短時間実行してから終了
import Foundation
DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
    exit(0)
}

SwiftTUI.run {
    HStackBackgroundDebugView()
}