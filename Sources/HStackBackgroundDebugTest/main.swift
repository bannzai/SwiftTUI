// HStackBackgroundDebugTest - CellRenderLoopのデバッグ出力でHStack背景色問題を調査
//
// Expected behavior:
// - CellRenderLoop.DEBUGを有効化して詳細なレンダリング情報を出力
// - HStack内の3つのText要素に赤、緑、青の背景色を適用
// - 0.5秒後に自動終了
//
// Note: CellRenderLoopの内部動作を詳細にトレースするためのテスト
//
// How to run: swift run HStackBackgroundDebugTest

// 実行時にプロセスが終了しないよう、短時間実行してから終了
import Foundation
import SwiftTUI

// デバッグ出力を有効化
CellRenderLoop.DEBUG = true

struct HStackBackgroundDebugView: View {
  var body: some View {
    VStack {
      Text("Debug HStack Background Issue")
      HStack {
        Text("A").background(.red)
        Text("B").background(.green)
        Text("C").background(.blue)
      }
    }
  }
}

DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
  exit(0)
}

SwiftTUI.run {
  HStackBackgroundDebugView()
}
