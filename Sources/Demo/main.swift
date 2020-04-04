import SwiftTUI
import Foundation
import cncurses
import Runtime

struct ContentView: View {
    var body: some View {
        Text("123").border()
    }
}
let view = ContentView()
let hostViewController = HostViewController(root: view)
Application(viewController: hostViewController).run()


//foo(view)
