import SwiftTUI
import Foundation

print("Interactive Form Test")
print("Use Tab/Shift+Tab to navigate between fields")
print("Press Ctrl+C to exit\n")

// CLAUDE.mdの理想的なフォーム例を実装
struct FormView: View {
    @State private var username = ""
    @State private var age = ""
    @State private var submitted = false
    
    var body: some View {
        VStack(spacing: 1) {
            Text("ユーザー登録")
                .bold()
                .padding(.bottom, 2)
            
            HStack {
                Text("ユーザー名:")
                    .foregroundColor(.green)
                TextField("ユーザー名を入力", text: $username)
                    .frame(width: 20)
            }
            .padding()
            
            HStack {
                Text("年齢:")
                    .foregroundColor(.green)
                    .padding(.trailing)
                TextField("年齢を入力", text: $age)
                    .frame(width: 10)
            }
            .padding()
            
            Button("送信") {
                submitted = true
                print("\n=== フォーム送信 ===")
                print("ユーザー名: \(username)")
                print("年齢: \(age)")
                print("==================\n")
            }
            .padding(.top, 2)
            
            if submitted {
                Text("送信完了！")
                    .foregroundColor(.yellow)
                    .background(.green)
                    .padding()
            }
        }
        .padding()
        .border()
    }
}

// メインループを開始
SwiftTUI.run {
    FormView()
}