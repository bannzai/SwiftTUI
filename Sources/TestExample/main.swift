import SwiftTUI
import Foundation

print("TestExample starting...")

// シンプルなテキストのみ
struct SimpleTextView: View {
    var body: some View {
        Text("Simple Text Test")
    }
}

print("Creating view...")
let view = SimpleTextView()

print("Starting SwiftTUI.run...")
SwiftTUI.run(view)