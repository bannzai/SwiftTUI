// SimpleStateTest - 自動状態更新の動作確認
//
// 期待される挙動:
// 1. "Simple State Test..."というメッセージが出力される
// 2. カウンター値（初期値: 0）が枠線付きで表示される
// 3. "Value updates every second"という説明が緑色で表示される
// 4. 1秒ごとにカウンターが自動的に増加する
// 5. RenderLoop.scheduleRedraw()により画面が再描画される
// 6. カウンターの値がリアルタイムで更新されて表示される
// 7. 5秒後に"Exiting..."メッセージが出力される
// 8. プログラムが自動的に終了する（カウンターは0〜4まで表示される）
//
// 注意: グローバル変数を使用し、Timerで定期的に更新することで
//       状態管理の基本的な動作を確認します
//
// 実行方法: swift run SimpleStateTest

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