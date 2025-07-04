import SwiftTUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Hello, SwiftTUI!")
                .padding()
                .border()
            
            HStack {
                Text("Left")
                Spacer()
                Text("Right")
            }
            .padding()
        }
    }
}

@main
struct SwiftUILikeExampleApp {
    static func main() {
        SwiftTUI.run(ContentView())
    }
}