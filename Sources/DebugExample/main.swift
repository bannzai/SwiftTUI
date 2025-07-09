// DebugExample - SwiftTUIの基本的な動作確認とAPI検証
//
// 期待される挙動:
// 1. "DEBUG: DebugExample started"が表示される
// 2. 直接LegacyTextをレンダリングし、バッファ内容を表示
// 3. SwiftUIライクなAPIでTextビューを表示
// 4. 5秒後に自動的にシャットダウンして終了
//
// 実行方法: swift run DebugExample

import SwiftTUI
import Foundation

print("DEBUG: DebugExample started")

// テスト1: 直接LegacyTextが動作することを確認
print("\nDEBUG: Test 1 - Direct LegacyText")
let legacyText = LegacyText("Direct Legacy Text")
var buffer1: [String] = []
legacyText.render(into: &buffer1)
print("Buffer: \(buffer1)")

// テスト2: 簡単なViewをSwiftTUI.runで実行（短時間で終了）
print("\nDEBUG: Test 2 - SwiftUI-like API")

struct SimpleView: View {
    var body: some View {
        Text("Hello from SwiftUI-like API!")
    }
}

// 5秒後に終了するようにスケジュール
DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
    print("\nDEBUG: Shutting down...")
    RenderLoop.shutdown()
    exit(0)
}

// SwiftTUI.runを実行
SwiftTUI.run(SimpleView())