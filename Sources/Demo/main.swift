import SwiftTUI
import Foundation
import cncurses
import Runtime

struct ContentView: View {
    var x: State<Bool>
    init(state: State<Bool>) {
        self.x = state
    }
    var body: some View {
        VStack(alignment: .leading) {
            if x.wrappedValue {
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
            } else {
                Text("World")
                Text(",")
                    .border(Color.yellow)
                    .padding(1)
                    .border(Color.red)
                    .frame(width: 7, height: 7)
                    .border(Color.blue)
                VStack(alignment: .trailing) {
                    Text("Hello")
                        .frame(width: 4, height: 3)
                }
            }
        }
        .border(.red)
        .border(.yellow)
    }
}
var state = State(initialValue: false)
let view = ContentView(state: state)
DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
    state.wrappedValue = true
    state.update()
}
Application(hostViewController: HostViewController(root: view)).run()

//foo(view)
