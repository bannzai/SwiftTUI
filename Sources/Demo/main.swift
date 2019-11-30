import SwiftTUI
import Foundation


print(
    ViewVisitor().visit(
        VStack {
            Text("Hello")
                .foregroundColor(.red)
            Text(", ")
            Text("World")
                .background(Color.blue)
            
        }
    )
)

//foo(view)
