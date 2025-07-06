import SwiftTUI

struct ESCTestView: View {
    var body: some View {
        VStack {
            Text("ESCキーテスト")
                .bold()
                .padding()
            
            Text("ESC キーを押して終了")
                .foregroundColor(.cyan)
        }
    }
}

SwiftTUI.run {
    ESCTestView()
}