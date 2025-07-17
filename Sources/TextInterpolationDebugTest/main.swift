import SwiftTUI

// Test specifically for string interpolation rendering
class TestModel: Observable {
  var count = 0 {
    didSet { notifyChange() }
  }
}

struct DebugView: View {
  @Environment(TestModel.self) var model: TestModel?

  var body: some View {
    VStack(spacing: 1) {
      Text("=== String Interpolation Debug ===")
        .bold()

      if let model = model {
        // Test 1: Simple interpolation with padding only (like SimpleObservableTest)
        Text("1. Count: \(model.count)")
          .padding()

        // Test 2: Interpolation with foregroundColor (like ObservableModelTest)
        Text("2. Count: \(model.count)")
          .foregroundColor(.green)
          .padding()

        // Test 3: String concatenation instead of interpolation
        Text("3. Count: " + String(model.count))
          .padding()

        // Test 4: Pre-computed string
        let countString = "4. Count: \(model.count)"
        Text(countString)
          .padding()

        // Test 5: Just the number
        Text("\(model.count)")
          .padding()

        // Test 6: With border (fixed)
        Text("6. Count: \(model.count)")
          .border()
          .padding()

        Button("Increment") {
          model.count += 1
          print("[DEBUG] Count updated to: \(model.count)")
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

// Create model and run
let model = TestModel()
print("[DEBUG] Initial count: \(model.count)")

GlobalKeyHandler.handler = { event in
  switch event.key {
  case .character("q"):
    print("\n[DEBUG] Final count: \(model.count)")
    print("Exiting...")
    CellRenderLoop.shutdown()
    return true
  default:
    return false
  }
}

SwiftTUI.run(
  DebugView()
    .environment(model)
)
