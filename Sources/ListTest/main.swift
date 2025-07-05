import SwiftTUI
import Foundation

struct Person: Identifiable {
    let id: Int
    let name: String
    let role: String
    let color: Color
}

struct ListTestView: View {
    let people = [
        Person(id: 1, name: "Alice", role: "Engineer", color: .green),
        Person(id: 2, name: "Bob", role: "Designer", color: .blue),
        Person(id: 3, name: "Charlie", role: "Manager", color: .yellow),
        Person(id: 4, name: "Diana", role: "Developer", color: .magenta),
        Person(id: 5, name: "Eve", role: "Analyst", color: .cyan),
        Person(id: 6, name: "Frank", role: "Architect", color: .red),
        Person(id: 7, name: "Grace", role: "QA Lead", color: .white),
        Person(id: 8, name: "Henry", role: "DevOps", color: .orange)
    ]
    
    var body: some View {
        VStack {
            Text("List Test")
                .bold()
                .padding()
                .border()
            
            // Basic List with ForEach
            Text("Basic List:")
                .foregroundColor(.cyan)
                .padding(.top)
            
            List {
                ForEach(people) { person in
                    HStack {
                        Text("[\(person.id)]")
                            .foregroundColor(.white)
                            .padding(.trailing)
                        
                        Text(person.name)
                            .foregroundColor(person.color)
                            .frame(width: 10)
                        
                        Spacer()
                        
                        Text(person.role)
                            .foregroundColor(.green)
                    }
                    .padding(.vertical, 1)
                    .padding(.horizontal)
                }
            }
            .frame(height: 15)
            .border()
            .padding()
            
            // Simple List with static content
            Text("Static List:")
                .foregroundColor(.cyan)
                .padding(.top)
            
            List {
                VStack {
                    Text("First item")
                        .padding()
                        .background(.blue)
                    
                    Text("Second item")
                        .padding()
                        .background(.green)
                }
                
                VStack {
                    Text("Third item")
                        .padding()
                        .background(.yellow)
                    
                    Text("Fourth item")
                        .padding()
                        .background(.red)
                }
            }
            .frame(height: 10)
            .border()
            .padding()
        }
    }
}

// 5秒後に自動終了
DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
    print("\nExiting...")
    RenderLoop.shutdown()
}

SwiftTUI.run {
    ListTestView()
}