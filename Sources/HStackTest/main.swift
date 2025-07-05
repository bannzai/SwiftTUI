import SwiftTUI
import Foundation

print("HStackTest starting...")

// HStackのテスト
struct TestView: View {
    var body: some View {
        HStack {
            Text("Left")
            Text("Center")
            Text("Right")
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