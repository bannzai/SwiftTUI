import SwiftTUI
import Foundation

struct ContentView: View {
    var body: some View {
        Text("Single Text - No VStack")
    }
}

@main
struct SwiftUILikeExampleApp {
    static func main() {
        SwiftTUI.run(ContentView())
    }
}