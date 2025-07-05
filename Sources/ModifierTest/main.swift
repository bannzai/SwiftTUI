import SwiftTUI
import Foundation

print("ModifierTest starting...")

struct ModifierTestView: View {
    var body: some View {
        // 複数のModifierをチェイン
        Text("Combined Modifiers: padding + border")
            .padding(2)
            .border()
    }
}

// 短時間で終了
DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
    print("Exiting...")
    RenderLoop.shutdown()
    exit(0)
}

SwiftTUI.run(ModifierTestView())