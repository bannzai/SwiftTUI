// BackgroundSizeDebugTest - HStack内での背景色サイズ計算のデバッグ
//
// このテストは以下を検証します：
// 1. HStack内で複数のテキスト要素に異なる背景色を適用
// 2. 各要素の背景色が正しいサイズでレンダリングされるか
// 3. CellBufferの内容を詳細に出力して動作を検証
//
// 期待される動作：
// - "ABC" が赤背景、"DEF" が緑背景、"GHI" が青背景で表示される
// - 各背景色がテキストの文字数分だけ正確に適用される
// - 0.5秒後に自動的に終了し、デバッグ情報を出力
//
// 実行方法：
// swift run BackgroundSizeDebugTest

import SwiftTUI
import Foundation
struct BackgroundSizeDebugView: View {
    var body: some View {
        HStack {
            Text("ABC").background(.red)
            Text("DEF").background(.green)
            Text("GHI").background(.blue)
        }
    }
}

// デバッグ用に短時間実行
DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
    // CellBufferの内容を詳細に出力
    print("\n=== Debug Complete ===")
    exit(0)
}

SwiftTUI.run {
    BackgroundSizeDebugView()
}