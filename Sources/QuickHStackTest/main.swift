import SwiftTUI
import Foundation

// 短時間で終了するHStackテスト
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