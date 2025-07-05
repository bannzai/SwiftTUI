import SwiftTUI

struct DirectionalPaddingTestView: View {
    var body: some View {
        VStack(spacing: 2) {
            Text("Directional Padding Test")
                .bold()
                .padding(Edge.bottom, 3)
            
            // Group 1: Individual directions
            VStack(spacing: 1) {
                Text("Top padding: 2")
                    .padding(Edge.top, 2)
                    .background(.blue)
                    .border()
                
                Text("Bottom padding: 2")
                    .padding(Edge.bottom, 2)
                    .background(.green)
                    .border()
                
                Text("Leading padding: 3")
                    .padding(Edge.leading, 3)
                    .background(.yellow)
                    .border()
                
                Text("Trailing padding: 3")
                    .padding(Edge.trailing, 3)
                    .background(.red)
                    .border()
            }
            
            // Group 2: Edge sets
            VStack(spacing: 1) {
                Text("Horizontal padding: 2")
                    .padding(.horizontal, 2)
                    .background(.cyan)
                    .border()
                
                Text("Vertical padding: 2")
                    .padding(.vertical, 2)
                    .background(.magenta)
                    .border()
                
                Text("All padding: 1")
                    .padding()
                    .background(.white)
                    .border()
            }
        }
        .padding()
        .border()
    }
}

SwiftTUI.run {
    DirectionalPaddingTestView()
}