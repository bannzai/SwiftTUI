import SwiftTUI
import Foundation

let view = TupleView((Text(""), AnyView(Text(""))))

class ViewVisitor: Visitor {
    override func visit<T>(_ element: T) {
        if let view = element as? AnyViewWrappable {
            print("view: \(view)")
        }
    }
}

func foo<T>(_ view: TupleView<T>) {
    view.accept(visitor: ViewVisitor())
}
view.accept(visitor: ViewVisitor())


//foo(view)
