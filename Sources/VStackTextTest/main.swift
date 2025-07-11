import SwiftTUI
import Foundation

// Test VStack layout with multiple Text views
class Model: Observable {
    var message = "Hello" {
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
                // Replicate SimpleObservableTest structure
                Text("Line 1: Title")
                    .bold()
                    .padding()
                
                Text("Line 2: \(model.message)")
                    .foregroundColor(.green)
                    .padding()
                    .border()
                
                Text("Line 3: Count = \(model.count)")  // This is the one that doesn't show
                    .padding()
                
                Text("Line 4: Another text")
                    .padding()
                
                Button("Update") {
                    model.count += 1
                    model.message = "Updated \(model.count)"
                    print("[DEBUG] Count: \(model.count), Message: \(model.message)")
                }
                .padding()
            }
            .padding()
        } else {
            Text("No model")
                .padding()
        }
    }
}

// Enable debug to see layout info
CellRenderLoop.DEBUG = true

let model = Model()

GlobalKeyHandler.handler = { event in
    switch event.key {
    case .character("q"):
        CellRenderLoop.shutdown()
        return true
    case .character("d"):
        // Toggle debug
        CellRenderLoop.DEBUG = !CellRenderLoop.DEBUG
        print("[DEBUG] Debug mode: \(CellRenderLoop.DEBUG)")
        return true
    default:
        return false
    }
}

// Auto-exit after 3 seconds for testing
DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
    print("\n[DEBUG] Auto-exiting...")
    CellRenderLoop.shutdown()
}

SwiftTUI.run(
    TestView()
        .environment(model)
)