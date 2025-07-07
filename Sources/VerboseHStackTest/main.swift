// VerboseHStackTest - 詳細なデバッグ出力を含むHStackテスト
//
// 期待される挙動:
// 1. "=== Verbose HStack Test Start ==="が出力される
// 2. CellRenderLoop.DEBUGがtrueに設定され、詳細なデバッグ情報が出力される
// 3. HStack内に"A"（赤背景）、"B"（緑背景）、"C"（青背景）が横並びで表示される
// 4. デバッグ出力により以下の情報が確認できる:
//    - セルバッファへの書き込み処理
//    - 各要素の座標計算
//    - 背景色の適用プロセス
// 5. 0.2秒後に"=== Test Complete ==="が出力される
// 6. プログラムが強制終了される
//
// 注意: HStackのセルレンダリングプロセスを詳細に確認するための
//       開発者向けデバッグテストです
//
// 実行方法: swift run VerboseHStackTest

import SwiftTUI
import Foundation

print("=== Verbose HStack Test Start ===")

struct VerboseHStackTestView: View {
    var body: some View {
        HStack {
            Text("A").background(.red)
            Text("B").background(.green)
            Text("C").background(.blue)
        }
    }
}

// グローバルフラグでデバッグを有効化
CellRenderLoop.DEBUG = true

// 実行
SwiftTUI.run {
    VerboseHStackTestView()
}

// 短時間で強制終了
DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
    print("\n=== Test Complete ===")
    exit(0)
}