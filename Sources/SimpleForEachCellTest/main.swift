// SimpleForEachCellTest - ForEachとHStackの組み合わせの動作確認
//
// 期待される挙動:
// 1. "Simple ForEach Test (Press ESC to exit)"というタイトルが太字で表示される
// 2. HStack内でForEachにより["A", "B", "C"]の配列が処理される
// 3. "A"、"B"、"C"が横並びで表示される（それぞれ赤背景）
// 4. 各アイテムにパディングが適用される
// 5. 全体が枠線で囲まれる
// 6. ESCキーでプログラムが終了する
//
// 注意: セルベースレンダリングシステムでのForEachとHStackの
//       組み合わせをテストします
//
// 実行方法: swift run SimpleForEachCellTest

import SwiftTUI

struct SimpleForEachCellTestView: View {
    var body: some View {
        VStack {
            Text("Simple ForEach Test (Press ESC to exit)")
                .bold()
            
            // Simple ForEach with array
            HStack {
                ForEach(["A", "B", "C"], id: \.self) { item in
                    Text(item)
                        .background(Color.red)
                        .padding()
                }
            }
        }
        .border()
    }
}

@main
public struct SimpleForEachCellTestApp {
    public static func main() {
        SwiftTUI.run {
            SimpleForEachCellTestView()
        }
    }
}