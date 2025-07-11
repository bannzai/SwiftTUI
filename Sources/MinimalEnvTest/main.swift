import SwiftTUI

print("Starting simple environment test...")

// デバッグモードを有効化
CellRenderLoop.DEBUG = true

// グローバルキーハンドラーでqキーで終了できるようにする
GlobalKeyHandler.handler = { event in
    switch event.key {
    case .character("q"):
        print("\nExiting...")
        CellRenderLoop.shutdown()
        return true
    default:
        return false
    }
}

// Observable for testing
class TestModel: Observable {
    var value = "Test" {
        didSet { notifyChange() }
    }
}

struct TestView: View {
    @Environment(TestModel.self) var model: TestModel?
    
    var body: some View {
        VStack(spacing: 1) {
            if let model = model {
                Text("Observable + Environment Test")
                    .bold()
                    .padding()
                
                Text(model.value)
                    .foregroundColor(.green)
                    .padding()
                    .border()
                
                Button("Update") {
                    model.value = "Updated!"
                }
                .padding()
            } else {
                Text("No model")
                    .foregroundColor(.red)
            }
        }
        .padding()
    }
}

// ObservableのEnvironmentテスト
let model = TestModel()
SwiftTUI.run(
    TestView()
        .environment(model)
)