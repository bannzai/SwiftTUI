// QuickForEachTest - ForEachの自動テスト（2秒で終了）
//
// 期待される挙動:
// 1. "ForEach Test - Auto Exit"というタイトルが表示される
// 2. HStack内でForEachにより["Red", "Green", "Blue"]の配列が処理される
// 3. "Red"（赤背景）、"Green"（緑背景）、"Blue"（青背景）が横並びで表示される
// 4. 各アイテムにパディングが適用される
// 5. "If you see 3 colored backgrounds above, ForEach is working!"というメッセージが表示される
// 6. 全体が枠線で囲まれる
// 7. 2秒後に自動的にプログラムが終了する
//
// 注意: ForEachの基本的な動作を自動テストで確認します
//
// 実行方法: swift run QuickForEachTest

import Foundation
import SwiftTUI

struct QuickForEachTestView: View {
  var body: some View {
    VStack {
      Text("ForEach Test - Auto Exit")

      // Test ForEach with array
      HStack {
        ForEach(["Red", "Green", "Blue"], id: \.self) { color in
          Text(color)
            .background(color == "Red" ? Color.red : color == "Green" ? Color.green : Color.blue)
            .padding()
        }
      }

      Text("If you see 3 colored backgrounds above, ForEach is working!")
    }
    .border()
  }
}

// Auto-exit after 2 seconds
DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
  CellRenderLoop.shutdown()
}

SwiftTUI.run {
  QuickForEachTestView()
}
