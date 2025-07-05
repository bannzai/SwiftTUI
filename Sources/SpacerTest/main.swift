import SwiftTUI
import Foundation

print("SpacerTest starting...")

// Spacerのテスト
struct TestView: View {
    var body: some View {
        HStack {
            Text("Left")
            Spacer()
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