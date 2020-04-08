import SwiftTUI
import Foundation
import cncurses
import Runtime

struct ContentView: View {
    @Binding var x: Bool
    var body: some View {
        VStack(alignment: .leading) {
            if x {
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
var binding = Binding<Bool>.constant(false)
let view = ContentView(x: binding)
DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
    binding.wrappedValue = true
    binding.update()
}
Application(hostViewController: HostViewController(root: view)).run()

//foo(view)
