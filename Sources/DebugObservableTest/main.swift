import SwiftTUI

// シンプルなObservableのデバッグテスト
class TestModel: Observable {
    var value = 123 {
        didSet { 
            print("[DEBUG] Value changed to: \(value)")
            notifyChange()
        }
    }
}

struct DebugView: View {
    @Environment(TestModel.self) var model: TestModel?
    
    var body: some View {
        VStack(spacing: 1) {
            Text("Debug Observable Test")
                .bold()
                .padding()
            
            // 様々なパターンで数値を表示
            Text("Direct number: 456")
                .padding()
                .border()
            
            Text("String literal: Value")
                .padding()
                .border()
            
            if let model = model {
                // 文字列補間のテスト
                Text("Value: \(model.value)")
                    .padding()
                    .border()
                
                // String()を使った場合
                Text("Value with String: " + String(model.value))
                    .padding()
                    .border()
                
                // 別の変数に格納した場合
                let valueString = "Stored value: \(model.value)"
                Text(valueString)
                    .padding()
                    .border()
                
                // Button action
                Button("Increment") {
                    model.value += 1
                }
                .padding()
            } else {
                Text("Model is nil")
                    .foregroundColor(.red)
            }
        }
    }
}

// テスト実行
let model = TestModel()
print("[DEBUG] Starting with value: \(model.value)")

GlobalKeyHandler.handler = { event in
    switch event.key {
    case .character("q"):
        print("\nExiting...")
        CellRenderLoop.shutdown()
        return true
    case .character("+"):
        model.value += 1
        return true
    case .character("-"):
        model.value -= 1
        return true
    default:
        return false
    }
}

print("[DEBUG] Running SwiftTUI...")

SwiftTUI.run(
    DebugView()
        .environment(model)
)