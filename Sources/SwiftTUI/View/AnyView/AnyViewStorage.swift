//
//  AnyViewStorage.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/08.
//

import Foundation

internal class AnyViewStorageBase: View, ViewContentAcceptable, ViewGraphSetAcceptable {
    internal func accept(visitor: ViewContentVisitor) -> ViewContentVisitor.VisitResult {
        fatalLogger.fatal("Should override this method to subclass")
    }
    
    internal func accept(visitor: ViewGraphSetVisitor) -> ViewGraph {
        fatalLogger.fatal("Should override this method to subclass")
    }
}
