import SwiftTUI

// デバッグ用のシンプルなテスト
struct SimpleCellTestView: View {
    var body: some View {
        VStack {
            Text("Simple Cell Test")
            
            // 単一の背景色
            Text("RED")
                .background(.red)
            
            // 単一のボーダー
            Text("BORDER")
                .border()
        }
    }
}

SwiftTUI.run {
    SimpleCellTestView()
}