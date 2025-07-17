// DebugBackgroundTest - HStack内の背景色レンダリングをデバッグ
//
// Expected behavior:
// - HStack内の複数のText要素に異なる背景色を適用
// - spacingあり/なしの両方のケースで背景色の描画を検証
// - バッファ内容をstderrにデバッグ出力
//
// Note: HStack内での背景色重なり問題の調査用
//
// How to run: swift run DebugBackgroundTest

import Foundation
import SwiftTUI

struct DebugBackgroundTestView: View {
  var body: some View {
    VStack {
      Text("Debug HStack:")
      HStack {
        Text("AAA").background(.red)
        Text("BBB").background(.green)
        Text("CCC").background(.blue)
      }

      Text("")
      Text("With spacing:")
      HStack(spacing: 2) {
        Text("X").background(.red)
        Text("Y").background(.green)
        Text("Z").background(.blue)
      }
    }
  }
}

// デバッグのためバッファを出力
func debugPrintBuffer(_ buffer: [String]) {
  fputs("\n=== Buffer Debug ===\n", stderr)
  for (index, line) in buffer.enumerated() {
    let escaped = line.replacingOccurrences(of: "\u{1B}", with: "\\e")
    fputs("[\(index)]: '\(escaped)'\n", stderr)
  }
  fputs("==================\n", stderr)
}

SwiftTUI.run {
  DebugBackgroundTestView()
}
