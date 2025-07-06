import SwiftTUI

// デバッグ出力を有効にしたテスト
CellRenderLoop.DEBUG = true

struct CellDebugTestView: View {
    var body: some View {
        VStack {
            Text("Debug Test")
            
            HStack {
                Text("A").background(.red)
                Text("B").background(.green)
                Text("C").background(.blue)
            }
        }
    }
}

SwiftTUI.run {
    CellDebugTestView()
}