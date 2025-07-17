// ForEachCellTest - ForEachの各種パターンとセルレンダリングの動作確認
//
// 期待される挙動:
// 1. "ForEach Cell Test"というタイトルが太字で表示される
// 2. ForEachRange(0..<3)によるレンダリング:
//    - "Item 0"、"Item 1"、"Item 2"がシアン文字・赤背景で横並びで表示される
// 3. ForEach with Arrayによるレンダリング:
//    - "A"、"B"、"C"が白文字・緑背景で横並びで表示される
// 4. ForEach with Identifiableによるレンダリング:
//    - "First"、"Second"、"Third"が黒文字・黄背景で横並びで表示される
// 5. 各アイテムにパディングが適用される
// 6. 全体が枠線で囲まれる
// 7. ESCキーでプログラムが終了する
//
// 注意: ForEachの3つの異なる使用パターン（Range、Array、Identifiable）を
//       セルベースレンダリングシステムでテストします
//
// 実行方法: swift run ForEachCellTest

import SwiftTUI

struct ForEachCellTestView: View {
  var body: some View {
    VStack(spacing: 1) {
      Text("ForEach Cell Test")
        .bold()
        .padding()

      // ForEach with Range
      HStack {
        ForEachRange(0..<3) { i in
          Text("Item \(i)")
            .foregroundColor(.cyan)
            .background(Color.red)
            .padding()
        }
      }

      // ForEach with Array
      HStack {
        ForEach(["A", "B", "C"], id: \.self) { item in
          Text(item)
            .foregroundColor(.white)
            .background(Color.green)
            .padding()
        }
      }

      // ForEach with Identifiable
      HStack {
        ForEach([
          TestItem(id: "1", name: "First"),
          TestItem(id: "2", name: "Second"),
          TestItem(id: "3", name: "Third"),
        ]) { item in
          Text(item.name)
            .foregroundColor(.black)
            .background(Color.yellow)
            .padding()
        }
      }
    }
    .border()
  }
}

struct TestItem: Identifiable {
  let id: String
  let name: String
}

@main
public struct ForEachCellTestApp {
  public static func main() {
    SwiftTUI.run {
      ForEachCellTestView()
    }
  }
}
