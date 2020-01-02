//
//  TestHelper.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/11.
//

import Foundation
@testable import SwiftTUI

struct DebuggerView: View, ViewContentAcceptable {
    let closure: () -> Void
    
    var body: some View {
        EmptyView()
    }
    
    func accept<V>(visitor: V) -> ViewContentVisitor.VisitResult where V : ViewContentVisitor {
        closure()
        return visitor.visit(body)
    }
}
