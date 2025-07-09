// SwiftUILikeExample - SwiftUIスタイルの@mainエントリーポイントのデモ
//
// 期待される挙動:
// 1. @mainアトリビュートを使用したSwiftUIライクなアプリケーション構造
// 2. VStack内に3つのTextビューが縦に配置される
// 3. RenderLoop.DEBUGモードが有効でデバッグ情報が表示される
// 4. 'q'キーで終了可能
//
// 実行方法: swift run SwiftUILikeExample

import SwiftTUI
import Foundation

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Hello, SwiftTUI!")
            Text("This is a VStack test")
            Text("Third line of text")
        }
    }
}

@main
struct SwiftUILikeExampleApp {
    static func main() {
        // デバッグモードを有効化
        RenderLoop.DEBUG = true
        SwiftTUI.run(ContentView())
    }
}