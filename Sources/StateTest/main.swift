import SwiftTUI
import Foundation

print("State Test starting...")
print("Tab/Shift+Tab: Move focus, Enter/Space: Press button")

// Stateを使った動的UIのテスト
struct CounterView: View {
    @State private var count = 0
    @State private var message = "Hello"
    
    var body: some View {
        VStack {
            Text("@State Test Demo")
                .foregroundColor(.cyan)
                .padding()
                .border()
            
            Text("Counter: \(count)")
                .foregroundColor(.green)
                .padding()
            
            Text("Message: \(message)")
                .foregroundColor(.yellow)
                .padding()
            
            HStack {
                Button("Count++") { 
                    count += 1 
                }
                .padding()
                
                Button("Count--") { 
                    count -= 1 
                }
                .padding()
                
                Button("Toggle") { 
                    message = message == "Hello" ? "World" : "Hello"
                }
                .padding()
            }
            
            Text("Tab to navigate, Enter to press")
                .foregroundColor(.white)
                .padding(.top)
        }
    }
}

// グローバルキーハンドラーでqキーで終了できるようにする
GlobalKeyHandler.handler = { event in
    switch event.key {
    case .character("q"):
        print("\nExiting...")
        RenderLoop.shutdown()
        return true
    default:
        return false
    }
}

// Viewを起動
SwiftTUI.run {
    CounterView()
}