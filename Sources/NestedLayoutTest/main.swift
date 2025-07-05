import SwiftTUI
import Foundation

print("NestedLayoutTest starting...")

// ネストされたレイアウトのテスト
struct TestView: View {
    var body: some View {
        VStack {
            Text("Title")
            HStack {
                Text("Left")
                VStack {
                    Text("Top")
                    Text("Bottom")
                }
                Text("Right")
            }
            Text("Footer")
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