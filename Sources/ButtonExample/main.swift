import SwiftTUI

// デバッグフラグをオンにする
//CellRenderLoop.DEBUG = true

struct ButtonExample: View {
  var body: some View {
    VStack {
      Text("=== Button Test ===")
        .foregroundColor(.cyan)

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

SwiftTUI.run(ButtonExample())
