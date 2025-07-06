import SwiftTUI

// Textビューのセルレンダリングをテスト
struct TextCellRenderTestView: View {
    var body: some View {
        VStack {
            Text("Individual backgrounds:")
            Text("RED").background(.red)
            Text("GREEN").background(.green)
            Text("BLUE").background(.blue)
            
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
    TextCellRenderTestView()
}