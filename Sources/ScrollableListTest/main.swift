// ScrollableListTest - ScrollView内のリストのスクロール機能確認
//
// 期待される挙動:
// 1. "Scrollable List Test"というタイトルが枠線付きで表示される
// 2. "Use ↑↓ arrow keys to scroll"という操作説明がシアン色で表示される
// 3. ScrollView内に10人分のデータがリスト形式で表示される
// 4. 各項目には[ID]、名前（色付き）、役職（緑色）が横並びで表示される
// 5. ScrollViewは10行分の高さに制限され、枠線で囲まれる
// 6. 上下矢印キーでリストをスクロールできる
// 7. "ESC to exit"というメッセージが白色で表示される
// 8. 10秒後に自動的にプログラムが終了する
// 9. ESCキーでも即座に終了できる
//
// 注意: ForEachとScrollViewの組み合わせによるスクロール機能をテストします
//
// 実行方法: swift run ScrollableListTest

import SwiftTUI
import Foundation

struct Person: Identifiable {
    let id: Int
    let name: String
    let role: String
    let color: Color
}

struct ScrollableListView: View {
    let people = [
        Person(id: 1, name: "Alice", role: "Engineer", color: .green),
        Person(id: 2, name: "Bob", role: "Designer", color: .blue),
        Person(id: 3, name: "Charlie", role: "Manager", color: .yellow),
        Person(id: 4, name: "Diana", role: "Developer", color: .magenta),
        Person(id: 5, name: "Eve", role: "Analyst", color: .cyan),
        Person(id: 6, name: "Frank", role: "Architect", color: .red),
        Person(id: 7, name: "Grace", role: "QA Lead", color: .white),
        Person(id: 8, name: "Henry", role: "DevOps", color: .orange),
        Person(id: 9, name: "Iris", role: "Product Owner", color: .green),
        Person(id: 10, name: "Jack", role: "Tech Lead", color: .blue)
    ]
    
    var body: some View {
        VStack {
            Text("Scrollable List Test")
                .bold()
                .padding()
                .border()
            
            Text("Use ↑↓ arrow keys to scroll")
                .foregroundColor(.cyan)
                .padding()
            
            // ScrollViewでListを囲む（矢印キーでスクロール可能）
            ScrollView {
                VStack(spacing: 1) {
                    ForEach(people) { person in
                        VStack(alignment: .leading) {
                            HStack {
                                Text("[\(person.id)]")
                                    .foregroundColor(.white)
                                
                                Text(person.name)
                                    .foregroundColor(person.color)
                                    .frame(width: 10)
                                
                                Spacer()
                                
                                Text(person.role)
                                    .foregroundColor(.green)
                            }
                        }
                        .padding()
                        .frame(width: 40)
                    }
                }
            }
            .frame(height: 10)  // ビューポートの高さ（10行分）
            .border()
            .padding()
            
            Text("ESC to exit")
                .foregroundColor(.white)
        }
    }
}

// 10秒後に自動終了
DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
    print("\nExiting...")
    RenderLoop.shutdown()
}

SwiftTUI.run {
    ScrollableListView()
}