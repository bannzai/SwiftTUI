import SwiftTUI

struct SimpleButtonHStackTest: View {
  var body: some View {
    HStack(spacing: 1) {
      Button("A") {
        print("A pressed")
      }
      Button("B") {
        print("B pressed")
      }
      Button("C") {
        print("C pressed")
      }
    }
    .padding()
  }
}

SwiftTUI.run(SimpleButtonHStackTest())
