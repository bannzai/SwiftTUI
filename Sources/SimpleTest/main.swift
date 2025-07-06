// SimpleTest - 基本的なVStackの動作確認
//
// 期待される挙動:
// 1. VStackで3つのTextが縦方向に配置される
// 2. "First Line"、"Second Line"、"Third Line"が上から順に表示される
// 3. デバッグ出力が有効になっているため、レンダリング処理の詳細が出力される
// 4. ESCキーまたはCtrl+Cでプログラムが終了する
//
// 実行方法: swift run SimpleTest

import SwiftTUI
import Foundation

// VStackのテスト
struct VStackTestView: View {
    var body: some View {
        VStack {
            Text("First Line")
            Text("Second Line")
            Text("Third Line")
        }
    }
}

// デバッグ出力を有効化
RenderLoop.DEBUG = true

print("Starting VStack test...")
SwiftTUI.run(VStackTestView())