import SwiftTUI
import Foundation

struct DebugBackgroundTestView: View {
    var body: some View {
        VStack {
            Text("Debug HStack:")
            HStack {
                Text("AAA").background(.red)
                Text("BBB").background(.green)
                Text("CCC").background(.blue)
            }
            
            Text("")
            Text("With spacing:")
            HStack(spacing: 2) {
                Text("X").background(.red)
                Text("Y").background(.green)
                Text("Z").background(.blue)
            }
        }
    }
}

// デバッグのためバッファを出力
func debugPrintBuffer(_ buffer: [String]) {
    fputs("\n=== Buffer Debug ===\n", stderr)
    for (index, line) in buffer.enumerated() {
        let escaped = line.replacingOccurrences(of: "\u{1B}", with: "\\e")
        fputs("[\(index)]: '\(escaped)'\n", stderr)
    }
    fputs("==================\n", stderr)
}

SwiftTUI.run {
    DebugBackgroundTestView()
}