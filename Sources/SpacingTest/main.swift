import SwiftTUI

struct SpacingTestView: View {
    var body: some View {
        VStack {
            Text("VStack with default spacing (0)")
                .padding()
                .border()
            
            VStack(spacing: 2) {
                Text("Item 1")
                    .padding()
                    .background(.blue)
                
                Text("Item 2")
                    .padding()
                    .background(.green)
                
                Text("Item 3")
                    .padding()
                    .background(.yellow)
            }
            .padding()
            .border()
            
            Text("HStack with spacing: 3")
                .padding()
            
            HStack(spacing: 3) {
                Text("A")
                    .padding()
                    .background(.red)
                
                Text("B")
                    .padding()
                    .background(.cyan)
                
                Text("C")
                    .padding()
                    .background(.magenta)
            }
            .padding()
            .border()
        }
    }
}

SwiftTUI.run {
    SpacingTestView()
}