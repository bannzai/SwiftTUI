//
//  AnyViewStorage.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/08.
//

import Foundation

internal class AnyViewStorageBase: View {
    func _typeOf() -> _AcceptableType {
        .anyStorageBase
    }
    func accept<V: AnyViewVisitor>(visitor: V) -> V.VisitResult {
        fatalError("Should override this method to subclass")
    }
}
