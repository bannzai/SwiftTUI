import Darwin
import SwiftTUI

struct MinimalAlignmentTest: View {
  var body: some View {
    VStack {
      Text("Alignment Test - HStack with .top alignment")
        .bold()
        .padding()
      
      // Test 1: Simple text with different heights
      HStack(alignment: .top) {
        Text("A")
          .background(.red)
        Text("B\nB")
          .background(.green)
        Text("C\nC\nC")
          .background(.blue)
      }
      .padding()
      .border()
      
      Text("Expected: All text should be top-aligned")
        .padding()
      
      // Test 2: Text with border (like TextField)
      HStack(alignment: .top) {
        Text("Label:")
        Text("Content")
          .border()  // This adds height: 3
      }
      .padding()
      .border()
      
      Text("Expected: 'Label:' should be at the top")
        .padding()
      
      Button("Quit") {
        exit(0)
      }
    }
  }
}

SwiftTUI.run(MinimalAlignmentTest())