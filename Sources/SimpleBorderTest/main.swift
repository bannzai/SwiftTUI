import Foundation
import SwiftTUI

// Simple test for border issue
struct TestView: View {
  var body: some View {
    VStack(spacing: 2) {
      Text("Test 1: Simple Text")

      Text("Test 2: Text with border")
        .border()

      Text("Count: 42")
        .border()
        .padding()
    }
    .padding()
  }
}

// Run for 3 seconds then exit
DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
  print("\nAuto-exiting after 3 seconds...")
  CellRenderLoop.shutdown()
}

SwiftTUI.run(TestView())
