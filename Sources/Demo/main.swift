import SwiftTUI
import Foundation
import cncurses
import Runtime

struct Modifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .border(Color.yellow)
            .padding(1)
            .border(Color.red)
            .frame(width: 7, height: 7)
            .border(Color.blue)
    }
}
struct ChildView: View {
    @Binding var binding: Bool
    var body: some View {
        VStack {
            if binding {
                Text("Hello")
                Text(",")
                    .modifier(Modifier())
                VStack(alignment: .trailing) {
                    Text("World")
                        .frame(width: 4, height: 3)
                }
            } else {
                Text("World")
                Text(",")
                    .modifier(Modifier())
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

struct ParentView: View {
    var state: State<Bool>
    init(state: State<Bool>) {
        self.state = state
    }
    var body: some View {
        ChildView(binding: state.projectedValue)
    }
}
var state = State(initialValue: false)
let view = ParentView(state: state)
DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
    state.wrappedValue = true
    state.update()
}
Application(hostViewController: HostViewController(root: view)).run()

//foo(view)
