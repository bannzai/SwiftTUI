import SwiftTUI

// デバッグフラグを設定
CellRenderLoop.DEBUG = false  // 一旦無効にして動作確認

// シンプルなObservableモデル
class TestModel: Observable {
    var value = 0 {
        didSet { notifyChange() }
    }
}

// Observable無しのView
struct NoObservableView: View {
    var body: some View {
        Text("No Observable Test")
    }
}

// Observableを使うView
struct WithObservableView: View {
    @Environment(TestModel.self) var model: TestModel?
    
    var body: some View {
        VStack {
            if let model = model {
                Text("Value: \(model.value)")
            } else {
                Text("No model")
            }
        }
    }
}

// 最初にワーキングテストで確認
print("=== Working Test (No Environment) ===")
print("Before SwiftTUI.run")
// SwiftTUI.run(Text("This should work"))
print("Test completed without running SwiftTUI")