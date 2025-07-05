import SwiftTUI
import Foundation

print("State Test starting...")
print("Press 'u' to increment, 'd' to decrement")
print("Press 'm' to change message, 'q' to quit")

// グローバルな状態を保持（@Stateの制限を回避）
class GlobalState {
    static var count = 0
    static var message = "Hello"
}

// Stateを使った動的UIのテスト
struct CounterView: View {
    var body: some View {
        VStack {
            Text("State Test Demo")
                .foregroundColor(.cyan)
                .padding()
                .border()
            
            Text("Counter: \(GlobalState.count)")
                .foregroundColor(.green)
                .padding()
            
            Text("Message: \(GlobalState.message)")
                .foregroundColor(.yellow)
                .padding()
            
            Text("u: increment, d: decrement")
                .foregroundColor(.white)
            
            Text("m: toggle message, q: quit")
                .foregroundColor(.white)
        }
    }
}

// グローバルキーハンドラーを設定
GlobalKeyHandler.handler = { event in
    switch event.key {
    case .character("u"):
        GlobalState.count += 1
        RenderLoop.scheduleRedraw()
        return true
    case .character("d"):
        GlobalState.count -= 1
        RenderLoop.scheduleRedraw()
        return true
    case .character("m"):
        GlobalState.message = GlobalState.message == "Hello" ? "World" : "Hello"
        RenderLoop.scheduleRedraw()
        return true
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