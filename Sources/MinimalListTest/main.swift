// MinimalListTest - 最小限のListコンポーネントの動作確認
//
// 期待される挙動:
// 1. Listコンポーネントが表示される
// 2. リスト内にVStackが配置される
// 3. VStack内に2つのテキスト "Item 1" と "Item 2" が縦に並んで表示される
// 4. Listは各アイテム間に自動的にセパレーター（区切り線）を追加する
// 5. 3秒後に"Exiting..."メッセージが出力される
// 6. プログラムが自動的に終了する
//
// 注意: これは最小限のListテストで、ForEachを使用していない静的なコンテンツです
//
// 実行方法: swift run MinimalListTest

import SwiftTUI
import Foundation

struct MinimalListView: View {
    var body: some View {
        List {
            VStack {
                Text("Item 1")
                Text("Item 2")
            }
        }
    }
}

// 3秒後に自動終了
DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
    print("\nExiting...")
    RenderLoop.shutdown()
}

SwiftTUI.run {
    MinimalListView()
}