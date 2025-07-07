// ScrollViewTest - ScrollViewコンポーネントの動作確認
//
// 期待される挙動:
// 1. タイトル "ScrollView Test" が表示される
// 2. "Use arrow keys to scroll" という操作説明が表示される
// 3. Vertical ScrollView セクション:
//    - 高さ10の枠内に19個のアイテムが表示される
//    - 各行は交互に青とマゼンタの背景色
//    - ↑/↓キーで垂直スクロールできる
//    - スクロールバーが右側に表示される
// 4. Horizontal ScrollView セクション:
//    - 高さ5の枠内に14個のカラムが表示される
//    - 各カラムは交互に赤とシアンの背景色
//    - ←/→キーで水平スクロールできる
// 5. ESCキーでプログラムが終了する
//
// 注意: Range errorが修正済みで、クラッシュすることなく動作します
// ただし、実際のスクロール描画（コンテンツのクリッピング）は未実装の可能性があります
//
// 実行方法: swift run ScrollViewTest

import SwiftTUI

struct ScrollViewTestView: View {
    var body: some View {
        VStack {
            VStack {
                Text("ScrollView Test")
                    .bold()
                    .padding()
                    .border()
                
                Text("Use arrow keys to scroll")
                    .foregroundColor(.cyan)
                    .padding()
            }
            
            VStack {
                Text("Vertical ScrollView:")
                    .padding(.top)
                
                ScrollView {
                    VStack {
                        ForEachRange(1..<20) { i in
                            HStack {
                                Text("Row \(i)")
                                    .foregroundColor(.green)
                                Spacer()
                                Text("Item \(i)")
                                    .foregroundColor(.yellow)
                            }
                            .padding()
                            .background(i % 2 == 0 ? .blue : .magenta)
                        }
                    }
                }
                .frame(height: 10)
                .border()
                .padding()
            }
            
            VStack {
                Text("Horizontal ScrollView:")
                    .padding(.top)
                
                ScrollView {
                    HStack {
                        ForEachRange(1..<15) { i in
                            VStack {
                                Text("Col")
                                Text("\(i)")
                            }
                            .padding()
                            .background(i % 2 == 0 ? .red : .cyan)
                            .border()
                        }
                    }
                }
                .frame(height: 5)
                .border()
                .padding()
            }
        }
    }
}

SwiftTUI.run {
    ScrollViewTestView()
}