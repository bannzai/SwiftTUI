import SwiftTUI

struct Item: Identifiable {
    let id: Int
    let name: String
    let color: Color
}

struct ForEachTestView: View {
    let items = [
        Item(id: 1, name: "Apple", color: .red),
        Item(id: 2, name: "Banana", color: .yellow),
        Item(id: 3, name: "Orange", color: .orange),
        Item(id: 4, name: "Grape", color: .magenta),
        Item(id: 5, name: "Blueberry", color: .blue)
    ]
    
    var body: some View {
        VStack(spacing: 1) {
            VStack {
                Text("ForEach Test")
                    .bold()
                    .padding()
                    .border()
                
                Text("Using Identifiable:")
                    .foregroundColor(.cyan)
                    .padding(.top)
            }
            
            VStack {
                ForEach(items) { item in
                    HStack {
                        Text("\(item.id).")
                            .foregroundColor(.white)
                            .padding(.trailing)
                        
                        Text(item.name)
                            .foregroundColor(item.color)
                            .padding()
                            .background(item.color.opacity(0.3))
                    }
                    .padding(.vertical, 1)
                }
            }
            .padding()
            .border()
            
            // ForEach with Range
            Text("Using Range:")
                .foregroundColor(.cyan)
                .padding(.top)
            
            HStack(spacing: 2) {
                ForEachRange(0..<5) { index in
                    Text("\(index)")
                        .padding()
                        .background(index % 2 == 0 ? .green : .blue)
                        .border()
                }
            }
            .padding()
            
            // ForEach with KeyPath
            VStack {
                Text("Using KeyPath:")
                    .foregroundColor(.cyan)
                    .padding(.top)
                
                VStack {
                    ForEach(["Hello", "World", "from", "SwiftTUI"], id: \.self) { word in
                        Text(word)
                            .padding()
                            .border()
                    }
                }
                .padding()
            }
        }
    }
}

// Color opacity extension for the test
extension Color {
    func opacity(_ value: Double) -> Color {
        // For simplicity, just return the color itself
        // In a real implementation, we'd support transparency
        self
    }
}

SwiftTUI.run {
    ForEachTestView()
}