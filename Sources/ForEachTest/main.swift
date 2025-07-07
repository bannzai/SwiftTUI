// ForEachTest - ForEachの動作確認
//
// 期待される挙動:
// 1. タイトル "ForEach Test" が表示される
// 2. Using Identifiable セクション:
//    - 5つのアイテム（果物）がリスト表示される
//    - 各アイテムはID、名前、色付き背景で表示される
//    - Identifiableプロトコルを使用したForEach
// 3. Using Range セクション:
//    - 0〜4の数字が横並びで表示される
//    - 偶数は緑、奇数は青の背景色
//    - ForEachRangeを使用（Rangeでの繰り返し）
// 4. Using KeyPath セクション:
//    - 4つの単語が縦に並んで表示される
//    - 各単語は枠線付きで表示される
//    - KeyPath（\.self）を使用したForEach
// 5. ESCキーでプログラムが終了する
//
// 注意: ViewBuilder制限を10個まで拡張済みのため、コンパイル可能です
// ただし、ForEachの内容が正しく表示されない場合があります
//
// 実行方法: swift run ForEachTest

import SwiftTUI

struct Item: Identifiable {
    let id: Int
    let name: String
    let color: Color
}

struct ForEachTestView: View {
    let items = [
        Item(id: 1, name: "Apple", color: .red),
        Item(id: 2, name: "Banana", color: .yellow),
        Item(id: 3, name: "Orange", color: .orange),
        Item(id: 4, name: "Grape", color: .magenta),
        Item(id: 5, name: "Blueberry", color: .blue)
    ]
    
    var body: some View {
        VStack(spacing: 1) {
            VStack {
                Text("ForEach Test")
                    .bold()
                    .padding()
                    .border()
                
                Text("Using Identifiable:")
                    .foregroundColor(.cyan)
                    .padding(.top)
            }
            
            VStack {
                ForEach(items) { item in
                    HStack {
                        Text("\(item.id).")
                            .foregroundColor(.white)
                            .padding(.trailing)
                        
                        Text(item.name)
                            .foregroundColor(item.color)
                            .padding()
                            .background(item.color.opacity(0.3))
                    }
                    .padding(.vertical, 1)
                }
            }
            .padding()
            .border()
            
            // ForEach with Range
            Text("Using Range:")
                .foregroundColor(.cyan)
                .padding(.top)
            
            HStack(spacing: 2) {
                ForEachRange(0..<5) { index in
                    Text("\(index)")
                        .padding()
                        .background(index % 2 == 0 ? .green : .blue)
                        .border()
                }
            }
            .padding()
            
            // ForEach with KeyPath
            VStack {
                Text("Using KeyPath:")
                    .foregroundColor(.cyan)
                    .padding(.top)
                
                VStack {
                    ForEach(["Hello", "World", "from", "SwiftTUI"], id: \.self) { word in
                        Text(word)
                            .padding()
                            .border()
                    }
                }
                .padding()
            }
        }
    }
}

// Color opacity extension for the test
extension Color {
    func opacity(_ value: Double) -> Color {
        // For simplicity, just return the color itself
        // In a real implementation, we'd support transparency
        self
    }
}

SwiftTUI.run {
    ForEachTestView()
}