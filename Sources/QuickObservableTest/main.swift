import SwiftTUI
import Foundation

// Quick test to verify the fix
class Model: Observable {
    var message = "Hello, Observable!" {
        didSet { notifyChange() }
    }
    var count = 0 {
        didSet { notifyChange() }
    }
}

struct TestView: View {
    @Environment(Model.self) var model: Model?
    
    var body: some View {
        if let model = model {
            VStack(spacing: 1) {
                Text("Simple Observable Test")
                    .bold()
                    .padding()
                
                Text(model.message)
                    .foregroundColor(.green)
                    .padding()
                    .border()
                
                Text("Count: \(model.count)")
                    .padding()
            }
            .padding()
        } else {
            Text("No model")
        }
    }
}

let model = Model()

// Auto-exit after 2 seconds
DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
    print("\nExiting...")
    CellRenderLoop.shutdown()
}

SwiftTUI.run(TestView().environment(model))