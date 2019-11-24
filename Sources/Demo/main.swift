import SwiftTUI
import Foundation


print(
    ViewVisitor().visit(
        VStack {
            VStack {
                Text("Hello")
                    .foregroundColor(.red)
            }
            Text(", ")
            Text("World")
                .background(.blue)
        }
    )
)

//foo(view)
