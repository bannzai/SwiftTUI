import SwiftTUI
import Foundation

struct QuickForEachTestView: View {
    var body: some View {
        VStack {
            Text("ForEach Test - Auto Exit")
            
            // Test ForEach with array
            HStack {
                ForEach(["Red", "Green", "Blue"], id: \.self) { color in
                    Text(color)
                        .background(color == "Red" ? Color.red : color == "Green" ? Color.green : Color.blue)
                        .padding()
                }
            }
            
            Text("If you see 3 colored backgrounds above, ForEach is working!")
        }
        .border()
    }
}

// Auto-exit after 2 seconds
DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
    CellRenderLoop.shutdown()
}

SwiftTUI.run {
    QuickForEachTestView()
}