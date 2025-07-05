import SwiftTUI
import Foundation

// VStackのテスト
struct VStackTestView: View {
    var body: some View {
        VStack {
            Text("First Line")
            Text("Second Line")
            Text("Third Line")
        }
    }
}

// デバッグ出力を有効化
RenderLoop.DEBUG = true

print("Starting VStack test...")
SwiftTUI.run(VStackTestView())