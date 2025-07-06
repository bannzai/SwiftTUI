import SwiftTUI

struct ToggleTestView: View {
    @State private var isOn1 = false
    @State private var isOn2 = true
    @State private var isOn3 = false
    @State private var notificationsEnabled = true
    @State private var darkModeEnabled = false
    
    var body: some View {
        VStack(spacing: 2) {
            Text("Toggle Component Test")
                .bold()
                .padding()
                .border()
            
            VStack(spacing: 1) {
                Toggle("Simple Toggle", isOn: $isOn1)
                    .padding()
                
                Toggle("Initially On", isOn: $isOn2)
                    .padding()
                
                Toggle("Another Toggle", isOn: $isOn3)
                    .padding()
            }
            .border()
            .padding()
            
            VStack(spacing: 1) {
                Text("Settings")
                    .bold()
                    .padding(.bottom)
                
                Toggle("Enable Notifications", isOn: $notificationsEnabled)
                Toggle("Dark Mode", isOn: $darkModeEnabled)
            }
            .padding()
            .border()
            
            Text("Instructions:")
                .foregroundColor(.cyan)
                .padding(.top)
            
            VStack {
                Text("• Tab: Move focus between toggles")
                Text("• Space/Enter: Toggle on/off")
                Text("• ESC: Exit program")
            }
            .foregroundColor(.white)
            .padding()
            
            HStack {
                Text("Values:")
                Text("T1: \(isOn1 ? "ON" : "OFF")")
                    .foregroundColor(isOn1 ? .green : .red)
                Text("T2: \(isOn2 ? "ON" : "OFF")")
                    .foregroundColor(isOn2 ? .green : .red)
                Text("T3: \(isOn3 ? "ON" : "OFF")")
                    .foregroundColor(isOn3 ? .green : .red)
            }
            .padding()
        }
    }
}

SwiftTUI.run {
    ToggleTestView()
}