import SwiftTUI

struct SingleButtonDebug: View {
    var body: some View {
        Button("Test") {
            print("Clicked")
        }
    }
}

// デバッグフラグを有効化
CellRenderLoop.DEBUG = true

SwiftTUI.run(SingleButtonDebug())