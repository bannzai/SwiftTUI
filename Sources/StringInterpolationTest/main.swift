import Foundation
import SwiftTUI

// Test string interpolation in Text views
struct TestView: View {
  var body: some View {
    VStack(spacing: 1) {
      Text("Test 1: Plain text")
      Text("Test 2: Number 42")
      Text("Test 3: Count: \(42)")
      Text("Test 4: Count value is \(100)")

      // Test with variable
      let count = 0
      Text("Test 5: Count: \(count)")

      // Test with expression
      Text("Test 6: Sum: \(1 + 2)")
    }
    .padding()
  }
}

// Auto-exit after 3 seconds
DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
  print("\nAuto-exiting...")
  CellRenderLoop.shutdown()
}

SwiftTUI.run(TestView())
