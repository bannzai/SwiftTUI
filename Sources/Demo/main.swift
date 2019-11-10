import SwiftTUI
import Foundation


print(
    ViewVisitor().visit(
        Group {
            Text("Hello")
            Text(", ")
            Text("World")
        }
    )
)

//foo(view)
