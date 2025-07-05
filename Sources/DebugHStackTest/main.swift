import SwiftTUI
import Foundation

print("Debug HStack Test")
print("Testing HStack with Buttons rendering...")

struct DebugView: View {
    var body: some View {
        VStack {
            Text("Testing HStack with multiple buttons")
                .foregroundColor(.cyan)
            
            HStack {
                Button("Btn1") {
                    print("Button1 pressed")
                }
                
                Button("Btn2") {
                    print("Button2 pressed")
                }
                
                Button("Btn3") {
                    print("Button3 pressed")
                }
            }
            
            Text("Should see 3 buttons above")
                .foregroundColor(.yellow)
        }
    }
}

// Auto exit after 3 seconds
DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
    print("Exiting...")
    RenderLoop.shutdown()
}

SwiftTUI.run {
    DebugView()
}