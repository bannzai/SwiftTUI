import SwiftTUI
import Foundation

struct MinimalListView: View {
    var body: some View {
        List {
            VStack {
                Text("Item 1")
                Text("Item 2")
            }
        }
    }
}

// 3秒後に自動終了
DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
    print("\nExiting...")
    RenderLoop.shutdown()
}

SwiftTUI.run {
    MinimalListView()
}