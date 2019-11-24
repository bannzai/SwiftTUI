import SwiftTUI
import Foundation


print(
    ViewVisitor().visit(
        Group {
            Text("Hello")
                .foregroundColor(.red)
            Text(", ")
            Text("World")
                .background(.blue)
        }
    )
)

//foo(view)
