// CellHStackDebugTest - HStackのセルレンダリングデバッグテスト
//
// 概要:
// HStack内での背景色レンダリングの動作を確認するためのテスト。
// CellRenderLoopのデバッグモードを有効にして、各要素の背景色がどのように
// レンダリングされるかを検証する。
//
// 期待される動作:
// - HStack内に3つのText要素が横並びで表示される
// - 各Textは異なる背景色（赤、緑、青）を持つ
// - CellRenderLoop.DEBUG = true により詳細なレンダリング情報が出力される
//
// 既知の問題:
// - 現在のレンダリングシステムでは、隣接する要素の背景色が正しく表示されない場合がある
// - 最後の要素の背景色が前の要素を上書きする可能性がある
//
// 実行方法:
// swift run CellHStackDebugTest

import SwiftTUI

// HStackのセルレンダリングをデバッグ
CellRenderLoop.DEBUG = true

struct CellHStackDebugView: View {
  var body: some View {
    HStack {
      Text("A").background(.red)
      Text("B").background(.green)
      Text("C").background(.blue)
    }
  }
}

SwiftTUI.run {
  CellHStackDebugView()
}
