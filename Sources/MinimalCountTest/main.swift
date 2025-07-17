import Foundation
import SwiftTUI

// Minimal test for count display issue
class Model: Observable {
  var count = 0 {
    didSet { notifyChange() }
  }
}

struct MinimalView: View {
  @Environment(Model.self) var model: Model?

  var body: some View {
    VStack(spacing: 1) {
      // Test different ways of displaying count
      Text("Test 1: Direct number 42")

      if let model = model {
        Text("Test 2: Count is \(model.count)")
        Text("Test 3: " + String(model.count))
        Text("Test 4: Count = " + "\(model.count)")

        // Create string first
        let countStr = "Count: \(model.count)"
        Text(countStr)

        Button("Increment") {
          model.count += 1
          print("Count incremented to: \(model.count)")
        }
      } else {
        Text("Model not found")
      }
    }
    .padding()
  }
}

// Enable debug
CellRenderLoop.DEBUG = true

// Create model
let model = Model()
print("Initial count: \(model.count)")

// Auto-exit after 5 seconds
DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
  print("\nFinal count: \(model.count)")
  print("Exiting...")
  CellRenderLoop.shutdown()
}

SwiftTUI.run(
  MinimalView()
    .environment(model)
)
