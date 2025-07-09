import SwiftTUI

struct DebugButtonTest: View {
    var body: some View {
        VStack {
            Text("Single Button Test")
                .padding()
                
            Button("Click Me") {
                print("Button clicked")
            }
            .padding()
            
            Text("HStack Button Test")
                .padding()
                
            HStack {
                Button("A") {
                    print("A")
                }
                
                Button("B") {
                    print("B")
                }
            }
            .padding()
        }
    }
}

SwiftTUI.run(DebugButtonTest())
