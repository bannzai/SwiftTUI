import SwiftTUI
import Foundation

struct SimpleScrollableListView: View {
    var body: some View {
        VStack {
            Text("SwiftTUIでのスクロールの仕組み")
                .bold()
                .padding()
                .border()
            
            Text("↑↓ キーでスクロール")
                .foregroundColor(.cyan)
                .padding()
            
            // ScrollViewで高さを制限して、スクロール可能にする
            ScrollView {
                VStack(spacing: 2) {
                    VStack {
                        Text("1. SwiftTUIのListは")
                            .foregroundColor(.green)
                            .padding()
                        
                        Text("2. 自動スクロールしない")
                            .foregroundColor(.yellow)
                            .padding()
                        
                        Text("3. ScrollViewで囲む必要がある")
                            .foregroundColor(.cyan)
                            .padding()
                        
                        Text("4. frameで高さを指定")
                            .foregroundColor(.magenta)
                            .padding()
                        
                        Text("5. すると表示領域が制限される")
                            .foregroundColor(.blue)
                            .padding()
                    }
                    
                    VStack {
                        Text("6. 矢印キーでスクロール可能に")
                            .foregroundColor(.red)
                            .padding()
                        
                        Text("7. これがSwiftUIとの違い")
                            .foregroundColor(.white)
                            .padding()
                        
                        Text("8. SwiftUIのListは自動スクロール")
                            .foregroundColor(.green)
                            .padding()
                        
                        Text("9. SwiftTUIは明示的なScrollView")
                            .foregroundColor(.yellow)
                            .padding()
                        
                        Text("10. InkのReactパターンに近い")
                            .foregroundColor(.cyan)
                            .padding()
                    }
                }
            }
            .frame(height: 8)  // 8行分の高さ（コンテンツは10行）
            .border()
            .padding()
            
            Text("ESC で終了")
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
    SimpleScrollableListView()
}