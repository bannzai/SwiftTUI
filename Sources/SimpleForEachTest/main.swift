import SwiftTUI

struct SimpleForEachView: View {
    var body: some View {
        VStack {
            Text("ForEach Test")
                .bold()
            
            ForEachRange(0..<3) { i in
                Text("Item \(i)")
            }
        }
    }
}

SwiftTUI.run {
    SimpleForEachView()
}