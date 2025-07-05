import SwiftTUI
import Foundation

print("Simple State Test...")

// グローバル変数でStateをテスト
var globalCounter = 0

struct SimpleStateView: View {
    var body: some View {
        VStack {
            Text("Counter: \(globalCounter)")
                .padding()
                .border()
            
            Text("Value updates every second")
                .foregroundColor(.green)
        }
    }
}

// タイマーで値を更新
Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
    globalCounter += 1
    RenderLoop.scheduleRedraw()  // 手動で再描画をトリガー
}

// 5秒後に終了
DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
    print("\nExiting...")
    exit(0)
}

SwiftTUI.run {
    SimpleStateView()
}