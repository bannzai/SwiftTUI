import SwiftTUI

struct ForEachDebugView: View {
    var body: some View {
        VStack {
            Text("HStack with ForEach:")
                .foregroundColor(.cyan)
            
            HStack {
                ForEachRange(0..<3) { i in
                    Text("[\(i)]")
                        .border()
                }
            }
            
            Text("ForEach with bg color:")
                .foregroundColor(.cyan)
            
            HStack {
                ForEachRange(0..<3) { i in
                    Text("\(i)")
                        .background(i % 2 == 0 ? .green : .blue)
                }
            }
        }
    }
}

SwiftTUI.run {
    ForEachDebugView()
}