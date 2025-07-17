import SwiftTUI

// Test different combinations of border and padding
struct BorderTestView: View {
  var body: some View {
    VStack(spacing: 2) {
      Text("Border Debug Test")
        .bold()
        .padding()

      // Test 1: Just text
      Text("Test 1: Plain text")

      // Test 2: Text with padding
      Text("Test 2: With padding")
        .padding()

      // Test 3: Text with border
      Text("Test 3: With border")
        .border()

      // Test 4: Text with border then padding (like ObservableModelTest)
      Text("Test 4: Border then padding")
        .border()
        .padding()

      // Test 5: Text with padding then border (like SimpleObservableTest)
      Text("Test 5: Padding then border")
        .padding()
        .border()

      // Test 6: Count interpolation with border+padding
      Text("Count: \(42)")
        .border()
        .padding()

      // Test 7: Count interpolation with padding+border
      Text("Count: \(42)")
        .padding()
        .border()
    }
    .padding()
  }
}

// Enable debug mode to see what's happening
CellRenderLoop.DEBUG = true

// Add q key handler
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

SwiftTUI.run(BorderTestView())
