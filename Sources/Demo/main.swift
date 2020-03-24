import SwiftTUI
import Foundation
import cncurses
import Runtime

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Hello")
                .foregroundColor(.red)
            Text(",")
            Text("World")
                .background(Color.blue)
        }
    }
}
let view = ContentView()
let hostViewController = HostViewController(root: view)
Application(viewController: hostViewController).run()


//foo(view)
