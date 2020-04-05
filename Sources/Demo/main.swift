import SwiftTUI
import Foundation
import cncurses
import Runtime

struct ContentView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Hello")
            Text(",")
                .border(Color.yellow)
                .padding(1)
                .border(Color.red)
                .frame(width: 7, height: 7)
                .border(Color.blue)
            VStack(alignment: .trailing) {
                Text("World")
                    .frame(width: 4, height: 3)
            }
        }
        .border(.red)
        .border(.yellow)
    }
}
let view = ContentView()
let hostViewController = HostViewController(root: view)
Application(viewController: hostViewController).run()


//foo(view)
