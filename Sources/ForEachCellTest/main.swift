import SwiftTUI

struct ForEachCellTestView: View {
    var body: some View {
        VStack(spacing: 1) {
            Text("ForEach Cell Test")
                .bold()
                .padding()
            
            // ForEach with Range
            HStack {
                ForEachRange(0..<3) { i in
                    Text("Item \(i)")
                        .foregroundColor(.cyan)
                        .background(Color.red)
                        .padding()
                }
            }
            
            // ForEach with Array
            HStack {
                ForEach(["A", "B", "C"], id: \.self) { item in
                    Text(item)
                        .foregroundColor(.white)
                        .background(Color.green)
                        .padding()
                }
            }
            
            // ForEach with Identifiable
            HStack {
                ForEach([
                    TestItem(id: "1", name: "First"),
                    TestItem(id: "2", name: "Second"),
                    TestItem(id: "3", name: "Third")
                ]) { item in
                    Text(item.name)
                        .foregroundColor(.black)
                        .background(Color.yellow)
                        .padding()
                }
            }
        }
        .border()
    }
}

struct TestItem: Identifiable {
    let id: String
    let name: String
}

@main
public struct ForEachCellTestApp {
    public static func main() {
        SwiftTUI.run {
            ForEachCellTestView()
        }
    }
}