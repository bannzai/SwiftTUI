import SwiftTUI
import Foundation

print("Key Test Verification")
print("Testing global key handler...")

// グローバルな状態
var testCount = 0

// グローバルキーハンドラーを設定
GlobalKeyHandler.handler = { event in
    print("Key pressed: \(event.key)")
    
    switch event.key {
    case .character("t"):
        testCount += 1
        print("Test count: \(testCount)")
        return true
    case .character("q"):
        print("Quitting...")
        RenderLoop.shutdown()
        return true
    default:
        return false
    }
}

struct TestView: View {
    var body: some View {
        VStack {
            Text("Press 't' to test, 'q' to quit")
                .foregroundColor(.cyan)
            
            Text("Test count: \(testCount)")
                .foregroundColor(.green)
        }
    }
}

// 3秒後に自動的に't'キーをシミュレート
DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
    print("\nSimulating 't' key press...")
    testCount += 1
    RenderLoop.scheduleRedraw()
}

// 5秒後に終了
DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
    print("Auto-exiting...")
    RenderLoop.shutdown()
}

SwiftTUI.run {
    TestView()
}