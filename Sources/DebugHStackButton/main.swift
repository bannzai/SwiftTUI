import SwiftTUI

// デバッグフラグをオンにする
CellRenderLoop.DEBUG = true

struct DebugHStackButton: View {
  var body: some View {
    VStack {
      Text("=== Debug HStack Button ===")
        .foregroundColor(.cyan)

      Text("Expected output: [ Click Me ]")
        .foregroundColor(.white)

      HStack {
        Text("[")
          .foregroundColor(.yellow)
        Button("Click Me") {
          print("Button clicked!")
        }
        Text("]")
          .foregroundColor(.yellow)
      }

      Text("")
      Text("Press Tab to focus button, Enter to click")
        .foregroundColor(.white)
    }
    .padding()
  }
}

SwiftTUI.run(DebugHStackButton())
