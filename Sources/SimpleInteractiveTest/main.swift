import SwiftTUI
import Foundation

print("Simple Interactive Test")
print("Tab: Next field, Shift+Tab: Previous field")
print("Enter/Space: Press button, Ctrl+C: Exit\n")

struct SimpleInteractiveView: View {
    @State private var name = ""
    @State private var counter = 0
    
    var body: some View {
        VStack {
            Text("Simple Interactive Demo")
                .foregroundColor(.cyan)
                .padding(2)
                .border()
            
            TextField("Enter your name", text: $name)
                .frame(width: 30)
            
            Text("Hello, \(name.isEmpty ? "World" : name)!")
                .foregroundColor(.green)
                .padding()
            
            HStack {
                Button("Increment") {
                    counter += 1
                }
                
                Text("Count: \(counter)")
                    .padding()
                    .background(.blue)
                
                Button("Reset") {
                    counter = 0
                    name = ""
                }
            }
        }
    }
}

SwiftTUI.run {
    SimpleInteractiveView()
}