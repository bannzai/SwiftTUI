import SwiftTUI
import Foundation

print("State Test starting...")

// Stateを使った動的UIのテスト
struct CounterView: View {
    @State private var count = 0
    @State private var message = "Hello"
    
    var body: some View {
        VStack {
            Text("Counter: \(count)")
                .foregroundColor(.cyan)
                .padding()
                .border()
            
            Text("Message: \(message)")
                .background(.blue)
                .padding()
            
            Text("Press 'u' to increment, 'd' to decrement")
                .foregroundColor(.green)
            
            Text("Press 'm' to change message, 'q' to quit")
                .foregroundColor(.yellow)
        }
    }
}

// 簡単なキーボード処理のシミュレーション
DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
    print("\nSimulating state changes...")
}

// 2秒後に終了
DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
    print("Exiting...")
    RenderLoop.shutdown()
    exit(0)
}

// Viewをクロージャとして渡す
SwiftTUI.run {
    CounterView()
}