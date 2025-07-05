import SwiftTUI
import Foundation

print("SimpleVStackTest starting...")

// 最小限のVStackテスト
struct TestView: View {
    var body: some View {
        VStack {
            Text("Line 1")
            Text("Line 2")
        }
    }
}

// 短時間で終了
DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
    print("Exiting...")
    RenderLoop.shutdown()
    exit(0)
}

SwiftTUI.run(TestView())