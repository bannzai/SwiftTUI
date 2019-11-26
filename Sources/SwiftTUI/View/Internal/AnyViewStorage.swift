//
//  AnyViewStorage.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/08.
//

import Foundation

internal class AnyViewStorageBase: View, Acceptable {
    var _baseProperty: _ViewBaseProperties? { nil }
    
    func accept<V: AnyViewVisitor>(visitor: V) -> V.VisitResult {
        fatalError("Should override this method to subclass")
    }
    func accept<V: AnyListViewVisitor>(visitor: V) -> AnyListViewVisitor.VisitResult  {
        fatalError("Should override this method to subclass")
    }
}
