import SwiftTUI

struct BorderHStackTestView: View {
    var body: some View {
        VStack {
            Text("Simple HStack with borders:")
                .foregroundColor(.cyan)
            
            HStack {
                Text("A")
                    .border()
                Text("B")
                    .border()
                Text("C")
                    .border()
            }
            
            Text("")
            Text("HStack with backgrounds:")
                .foregroundColor(.cyan)
            
            HStack {
                Text("1")
                    .background(.red)
                Text("2")
                    .background(.green)
                Text("3")
                    .background(.blue)
            }
            
            Text("")
            Text("Both border and background:")
                .foregroundColor(.cyan)
            
            HStack {
                Text("X")
                    .background(.yellow)
                    .border()
                Text("Y")
                    .background(.magenta)
                    .border()
            }
        }
    }
}

SwiftTUI.run {
    BorderHStackTestView()
}