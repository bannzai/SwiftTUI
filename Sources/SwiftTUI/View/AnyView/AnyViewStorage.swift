//
//  AnyViewStorage.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/08.
//

import Foundation

internal class AnyViewStorageBase: View, ViewContentAcceptable, ViewGraphSetAcceptable {
    internal func accept(visitor: ViewContentVisitor) -> ViewContentVisitor.VisitResult {
        fatalError("Should override this method to subclass")
    }
    
    internal func accept(visitor: ViewGraphSetVisitor) -> ViewGraph {
        fatalError("Should override this method to subclass")
    }
}
