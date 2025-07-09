import SwiftTUI

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

SwiftTUI.run(
    SimpleView()
        .environment(model)
)