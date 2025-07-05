import SwiftTUI

struct DirectionalPaddingTestView: View {
    var body: some View {
        VStack(spacing: 2) {
            Text("Directional Padding Test")
                .bold()
                .padding(.bottom, 3)
            
            // Test all directions
            Text("Top padding: 2")
                .padding(.top, 2)
                .background(.blue)
                .border()
            
            Text("Bottom padding: 2")
                .padding(.bottom, 2)
                .background(.green)
                .border()
            
            Text("Leading padding: 3")
                .padding(.leading, 3)
                .background(.yellow)
                .border()
            
            Text("Trailing padding: 3")
                .padding(.trailing, 3)
                .background(.red)
                .border()
            
            // Test edge sets
            Text("Horizontal padding: 2")
                .padding(.horizontal, 2)
                .background(.cyan)
                .border()
            
            Text("Vertical padding: 2")
                .padding(.vertical, 2)
                .background(.magenta)
                .border()
            
            // Test combined padding
            Text("All padding: 1")
                .padding()
                .background(.white)
                .border()
        }
        .padding()
        .border()
    }
}

SwiftTUI.run {
    DirectionalPaddingTestView()
}