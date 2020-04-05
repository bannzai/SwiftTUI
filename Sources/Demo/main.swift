import SwiftTUI
import Foundation
import cncurses
import Runtime

struct ContentView: View {
    var body: some View {
        Text("123").frame(width: 0, height: 0)
    }
}
let view = ContentView()
let hostViewController = HostViewController(root: view)
Application(viewController: hostViewController).run()


//foo(view)
