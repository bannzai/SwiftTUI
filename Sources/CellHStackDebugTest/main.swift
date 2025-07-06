import SwiftTUI

// HStackのセルレンダリングをデバッグ
CellRenderLoop.DEBUG = true

struct CellHStackDebugView: View {
    var body: some View {
        HStack {
            Text("A").background(.red)
            Text("B").background(.green) 
            Text("C").background(.blue)
        }
    }
}

SwiftTUI.run {
    CellHStackDebugView()
}