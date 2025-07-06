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