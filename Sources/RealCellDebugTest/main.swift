import SwiftTUI
import Foundation

// 実際のSwiftTUIビューでのデバッグ
struct RealCellDebugView: View {
    var body: some View {
        VStack {
            Text("Single text with background:")
            Text("RED").background(.red)
            
            Text("\nHStack with backgrounds:")
            HStack {
                Text("A").background(.red)
                Text("B").background(.green) 
                Text("C").background(.blue)
            }
        }
    }
}

// デバッグモードを有効化
CellRenderLoop.DEBUG = true

SwiftTUI.run {
    RealCellDebugView()
}