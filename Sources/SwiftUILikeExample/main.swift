import SwiftTUI
import Foundation

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Hello, SwiftTUI!")
            Text("This is a VStack test")
            Text("Third line of text")
        }
    }
}

@main
struct SwiftUILikeExampleApp {
    static func main() {
        // デバッグモードを有効化
        RenderLoop.DEBUG = true
        SwiftTUI.run(ContentView())
    }
}