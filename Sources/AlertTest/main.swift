import SwiftTUI

struct AlertTestView: View {
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var actionCount = 0
    
    var body: some View {
        if showAlert {
            // Alertを表示
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Alert(
                        title: "Alert Test",
                        message: alertMessage,
                        dismiss: {
                            showAlert = false
                        }
                    )
                    Spacer()
                }
                Spacer()
            }
        } else {
            // 通常のコンテンツ
            VStack(spacing: 2) {
                Text("Alert Component Test")
                    .bold()
                    .padding()
                    .border()
                
                VStack(spacing: 2) {
                    Button("Show Simple Alert") {
                        alertMessage = "This is a simple alert message."
                        showAlert = true
                        actionCount += 1
                    }
                    .padding()
                    
                    Button("Show Warning") {
                        alertMessage = "Warning: This action cannot be undone!"
                        showAlert = true
                        actionCount += 1
                    }
                    .padding()
                    
                    Button("Show Error") {
                        alertMessage = "Error: Something went wrong."
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
        }
    }
}

SwiftTUI.run {
    AlertTestView()
}