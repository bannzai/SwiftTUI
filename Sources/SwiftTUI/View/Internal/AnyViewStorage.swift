//
//  AnyViewStorage.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/08.
//

import Foundation

internal class AnyViewStorageBase: View, ViewContentAcceptable, ViewSizeAcceptable {
    var _baseProperty: _ViewBaseProperties? { nil }
    
    internal func accept(visitor: ViewContentVisitor) -> ViewContentVisitor.VisitResult {
        fatalError("Should override this method to subclass")
    }
    
    internal func accept(visitor: ViewSizeVisitor) -> ViewSizeVisitor.VisitResult {
        fatalError("Should override this method to subclass")
    }
}
