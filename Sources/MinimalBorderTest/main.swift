import SwiftTUI

// Minimal test to debug border issue
struct MinimalBorderView: View {
  var body: some View {
    VStack(spacing: 2) {
      // This works
      Text("Works: padding then border")
        .padding()
        .border()

      // This doesn't show text
      Text("Broken: border only")
        .border()

      // This also doesn't show text
      Text("Also broken: border then padding")
        .border()
        .padding()
    }
    .padding()
  }
}

// Enable debug mode
CellRenderLoop.DEBUG = true

// q to quit
GlobalKeyHandler.handler = { event in
  switch event.key {
  case .character("q"):
    CellRenderLoop.shutdown()
    return true
  default:
    return false
  }
}

SwiftTUI.run(MinimalBorderView())
