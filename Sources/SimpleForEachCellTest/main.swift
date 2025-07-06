import SwiftTUI

struct SimpleForEachCellTestView: View {
    var body: some View {
        VStack {
            Text("Simple ForEach Test (Press ESC to exit)")
                .bold()
            
            // Simple ForEach with array
            HStack {
                ForEach(["A", "B", "C"], id: \.self) { item in
                    Text(item)
                        .background(Color.red)
                        .padding()
                }
            }
        }
        .border()
    }
}

@main
public struct SimpleForEachCellTestApp {
    public static func main() {
        SwiftTUI.run {
            SimpleForEachCellTestView()
        }
    }
}