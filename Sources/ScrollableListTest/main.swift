import SwiftTUI
import Foundation

struct Person: Identifiable {
    let id: Int
    let name: String
    let role: String
    let color: Color
}

struct ScrollableListView: View {
    let people = [
        Person(id: 1, name: "Alice", role: "Engineer", color: .green),
        Person(id: 2, name: "Bob", role: "Designer", color: .blue),
        Person(id: 3, name: "Charlie", role: "Manager", color: .yellow),
        Person(id: 4, name: "Diana", role: "Developer", color: .magenta),
        Person(id: 5, name: "Eve", role: "Analyst", color: .cyan),
        Person(id: 6, name: "Frank", role: "Architect", color: .red),
        Person(id: 7, name: "Grace", role: "QA Lead", color: .white),
        Person(id: 8, name: "Henry", role: "DevOps", color: .orange),
        Person(id: 9, name: "Iris", role: "Product Owner", color: .green),
        Person(id: 10, name: "Jack", role: "Tech Lead", color: .blue)
    ]
    
    var body: some View {
        VStack {
            Text("Scrollable List Test")
                .bold()
                .padding()
                .border()
            
            Text("Use ↑↓ arrow keys to scroll")
                .foregroundColor(.cyan)
                .padding()
            
            // ScrollViewでListを囲む（矢印キーでスクロール可能）
            ScrollView {
                VStack(spacing: 1) {
                    ForEach(people) { person in
                        VStack(alignment: .leading) {
                            HStack {
                                Text("[\(person.id)]")
                                    .foregroundColor(.white)
                                
                                Text(person.name)
                                    .foregroundColor(person.color)
                                    .frame(width: 10)
                                
                                Spacer()
                                
                                Text(person.role)
                                    .foregroundColor(.green)
                            }
                        }
                        .padding()
                        .frame(width: 40)
                    }
                }
            }
            .frame(height: 10)  // ビューポートの高さ（10行分）
            .border()
            .padding()
            
            Text("ESC to exit")
                .foregroundColor(.white)
        }
    }
}

// 10秒後に自動終了
DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
    print("\nExiting...")
    RenderLoop.shutdown()
}

SwiftTUI.run {
    ScrollableListView()
}