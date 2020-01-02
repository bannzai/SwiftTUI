//
//  AnyViewStorage.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/08.
//

import Foundation

internal class AnyViewStorageBase: View, ViewContentAcceptable, _ViewSizeAcceptable {
    internal func accept(visitor: ViewContentVisitor) -> ViewContentVisitor.VisitResult {
        fatalError("Should override this method to subclass")
    }
    
    internal func accept(visitor: _ViewSizeVisitor, with argument: _ViewSizeVisitor.Argument) -> _ViewSizeVisitor.VisitResult {
        fatalError("Should override this method to subclass")
    }
}
