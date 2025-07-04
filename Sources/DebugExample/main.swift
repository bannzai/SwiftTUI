import SwiftTUI
import Foundation

// 最も簡単なケース - 単一のText
struct SimpleTextView: View {
    var body: some View {
        Text("Debug: Hello, SwiftTUI!")
    }
}

// 直接RenderLoopを使用して確認
print("Starting debug example...")

RenderLoop.mount {
    // 直接LegacyTextで確認
    LegacyText("Direct LegacyText Test")
}

// メインループを開始
dispatchMain()