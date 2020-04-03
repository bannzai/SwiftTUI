import SwiftTUI
import Foundation
import cncurses
import Runtime

struct ContentView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Hello")
            VStack(alignment: .trailing) {
                Text(",")
                Text("World")
            }
        }
    }
}
let view = ContentView()
let hostViewController = HostViewController(root: view)
Application(viewController: hostViewController).run()


//foo(view)
