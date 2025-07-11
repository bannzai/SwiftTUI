import SwiftTUI

print("[SimpleObservableTest] Starting...")

// Observable実装のテスト（WWDC23スタイル）
class MessageModel: Observable {
    var message = "Hello, Observable!" {
        didSet { notifyChange() }
    }
    var count = 0 {
        didSet { notifyChange() }
    }
    
    func updateMessage() {
        count += 1
        message = "Updated \(count) times"
    }
}

struct SimpleView: View {
    @Environment(MessageModel.self) var model: MessageModel?
    
    var body: some View {
        VStack(spacing: 1) {
            if let model = model {
                Text("Observable + Environment Test")
                    .bold()
                    .padding()
                
                Text(model.message)
                    .foregroundColor(.green)
                    .padding()
                    .border()
                
                Text("Count: \(model.count)")
                    .padding()
                
                Button("Update") {
                    model.updateMessage()
                }
                .padding()
            } else {
                Text("No model in environment")
                    .foregroundColor(.red)
            }
        }
        .padding()
    }
}

// Test
let model = MessageModel()

print("[SimpleObservableTest] Model created")

// グローバルキーハンドラーでqキーで終了できるようにする
GlobalKeyHandler.handler = { event in
    switch event.key {
    case .character("q"):
        print("\n[SimpleObservableTest] Exiting...")
        CellRenderLoop.shutdown()
        return true
    default:
        return false
    }
}

print("[SimpleObservableTest] Running SwiftTUI.run...")

// デバッグモード無効化
CellRenderLoop.DEBUG = false

SwiftTUI.run(
    SimpleView()
        .environment(model)
)