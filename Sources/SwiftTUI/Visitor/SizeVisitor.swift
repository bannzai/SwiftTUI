//
//  ExplicitSizeVisitor.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/27.
//

import Foundation

open class AnySizeVisitor: Visitor {
    public typealias VisitResult = Size?
    public func visit<T: View>(_ content: T) -> AnySizeVisitor.VisitResult {
        fatalError("Should override this method to subclass")
    }
}
