import SwiftTUI
import Foundation
import cncurses
import Runtime

struct ContentView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Hello")
                .alignmentGuide(.leading, computeValue: { _ in return 1 })
                .alignmentGuide(.leading, computeValue: { d in d[explicit: .leading]! + 2 })
                .background(Color.red)
            Text(",")
            Text("World")
        }
    }
}
let view = ContentView()
let hostViewController = HostViewController(root: view)
Application(viewController: hostViewController).run()


//foo(view)
