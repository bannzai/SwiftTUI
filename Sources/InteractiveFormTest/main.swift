// InteractiveFormTest - インタラクティブフォームの動作確認
//
// 期待される挙動:
// 1. "Interactive Form Test"と操作説明が表示される
// 2. 枠線で囲まれたフォームが表示される
// 3. "ユーザー登録"というタイトルが表示される
// 4. 2つの入力フィールド: ユーザー名（幅20）、年齢（幅10）
// 5. Tab/Shift+Tabキーでフィールド間を移動できる
// 6. TextFieldに文字を入力でき、Backspaceで削除できる
// 7. "送信"ボタンをEnter/Spaceキーでクリックできる
// 8. 送信すると入力内容がコンソールに出力される
// 9. 送信後、"送信完了！"メッセージが黄色文字・緑背景で表示される
// 10. ESCキーまたはCtrl+Cでプログラムが終了する
//
// 実行方法: swift run InteractiveFormTest

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
                .padding(Edge.bottom, 2)
            
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
            .padding(Edge.top, 2)
            
            Group {
                if submitted {
                    Text("送信完了！")
                        .foregroundColor(.yellow)
                        .background(.green)
                        .padding()
                } else {
                    EmptyView()
                }
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