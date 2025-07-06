import SwiftTUI

struct SimpleBackgroundTestView: View {
    var body: some View {
        VStack {
            Text("Single background:")
            Text("Hello")
                .background(.red)
            
            Text("")
            Text("Multiple backgrounds:")
            Text("A").background(.red)
            Text("B").background(.green)
            Text("C").background(.blue)
            
            Text("")
            Text("In HStack:")
            HStack {
                Text("1").background(.red)
                Text("2").background(.green)
                Text("3").background(.blue)
            }
        }
    }
}

SwiftTUI.run {
    SimpleBackgroundTestView()
}