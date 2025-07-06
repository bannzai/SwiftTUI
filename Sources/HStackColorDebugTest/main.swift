import SwiftTUI

// HStackの背景色問題をデバッグ
struct HStackColorDebugView: View {
    var body: some View {
        VStack {
            Text("Individual texts with background:")
            Text("A").background(.red)
            Text("B").background(.green)
            Text("C").background(.blue)
            
            Text("")
            Text("HStack with backgrounds:")
            HStack {
                Text("A").background(.red)
                Text("B").background(.green)
                Text("C").background(.blue)
            }
        }
    }
}

SwiftTUI.run {
    HStackColorDebugView()
}