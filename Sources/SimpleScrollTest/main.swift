import SwiftTUI
import Foundation

struct SimpleScrollTestView: View {
    var body: some View {
        VStack {
            Text("シンプルなScrollViewテスト")
                .bold()
                .padding()
            
            Text("↑↓ キーでスクロール")
                .foregroundColor(.cyan)
            
            ScrollView {
                VStack {
                    Text("1番目").foregroundColor(.green).padding()
                    Text("2番目").foregroundColor(.yellow).padding()
                    Text("3番目").foregroundColor(.cyan).padding()
                    Text("4番目").foregroundColor(.magenta).padding()
                    Text("5番目").foregroundColor(.blue).padding()
                }
            }
            .frame(height: 3)  // 3行分の高さ
            .border()
            
            Text("ESC で終了")
                .foregroundColor(.white)
        }
    }
}

// 30秒後に自動終了
DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
    print("\nExiting...")
    RenderLoop.shutdown()
}

SwiftTUI.run {
    SimpleScrollTestView()
}