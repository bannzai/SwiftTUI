import SwiftTUI

// 最小限のHStackテスト
struct SimpleHStackTestView: View {
    var body: some View {
        HStack {
            Text("A").background(.red)
            Text("B").background(.green)
            Text("C").background(.blue)
        }
    }
}

SwiftTUI.run {
    SimpleHStackTestView()
}