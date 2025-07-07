// AlertTest - Alert Modifierの動作確認
//
// 期待される挙動:
// 1. 画面にタイトル "Alert Component Test" と3つのボタンが表示される
// 2. 3つのボタン: "Show Simple Alert", "Show Warning", "Show Error"
// 3. Tabキーでボタン間のフォーカスを移動できる
// 4. Enter/Spaceキーでフォーカスされたボタンをクリックできる
// 5. ボタンをクリックするとアラートダイアログが表示される
// 6. アラートが表示されたらEnter/Space/ESCキーで閉じることができる
// 7. アラートが表示された回数がカウントされて表示される
// 8. ESCキーまたはCtrl+Cでプログラムが終了する
//
// 実行方法: swift run AlertTest

import SwiftTUI

struct AlertTestView: View {
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = "Alert Test"
    @State private var actionCount = 0
    
    var body: some View {
        VStack(spacing: 2) {
            Text("Alert Component Test")
                .bold()
                .padding()
                .border()
            
            VStack(spacing: 2) {
                Button("Show Simple Alert") {
                    alertTitle = "Information"
                    alertMessage = "This is a simple alert message."
                    showAlert = true
                    actionCount += 1
                }
                .padding()
                
                Button("Show Warning") {
                    alertTitle = "Warning"
                    alertMessage = "This action cannot be undone!"
                    showAlert = true
                    actionCount += 1
                }
                .padding()
                
                Button("Show Error") {
                    alertTitle = "Error"
                    alertMessage = "Something went wrong."
                    showAlert = true
                    actionCount += 1
                }
                .padding()
            }
            .border()
            .padding()
            
            Text("Instructions:")
                .foregroundColor(.cyan)
                .padding(.top)
            
            VStack {
                Text("• Tab: Move focus between buttons")
                Text("• Enter/Space: Show alert")
                Text("• When alert is shown:")
                Text("  - Enter/Space/ESC: Dismiss alert")
            }
            .foregroundColor(.white)
            .padding()
            
            Text("Alert shown \(actionCount) times")
                .foregroundColor(.yellow)
                .padding()
        }
        .alert(alertTitle, isPresented: $showAlert, message: alertMessage)
    }
}

SwiftTUI.run {
    AlertTestView()
}