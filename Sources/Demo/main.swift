import SwiftTUI
import Darwin.ncurses
import Foundation
import Darwin.ncurses

let hostViewController = HostViewController(root:
    VStack {
        Text("Hello")
            .foregroundColor(.red)
        Text(", ")
        Text("World")
            .background(Color.blue)
    }
)

Application(viewController: hostViewController).run()


//foo(view)
