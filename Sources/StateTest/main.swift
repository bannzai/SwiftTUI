import SwiftTUI
import Foundation

print("State Test starting...")

// グローバルな状態を保持（シンプルな動作確認のため）
class GlobalState {
    static var count = 0
    static var message = "Hello"
}

// Stateを使った動的UIのテスト
struct CounterView: View {
    var body: some View {
        VStack {
            Text("Counter: \(GlobalState.count)")
                .foregroundColor(.cyan)
                .padding()
                .border()
            
            Text("Message: \(GlobalState.message)")
                .background(.blue)
                .padding()
            
            Text("Press 'u' to increment, 'd' to decrement")
                .foregroundColor(.green)
            
            Text("Press 'm' to change message, 'q' to quit")
                .foregroundColor(.yellow)
        }
    }
}

// グローバルキーハンドラーを設定
GlobalKeyHandler.handler = { event in
    switch event.key {
    case .character("u"):
        GlobalState.count += 1
        return true
    case .character("d"):
        GlobalState.count -= 1
        return true
    case .character("m"):
        GlobalState.message = GlobalState.message == "Hello" ? "World" : "Hello"
        return true
    case .character("q"):
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