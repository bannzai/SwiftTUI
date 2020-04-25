//
//  ViewGraphSetVisitor.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2020/04/08.
//

import Foundation

internal final class ViewGraphSetVisitor: Visitor {
    internal var current: ViewGraph? = nil

    internal init() { }
    
    internal func visit<T: View>(_ view: T) -> ViewGraph {
        debugLogger.debug(userInfo: "begin graph set \(type(of: view))")
        defer {
            debugLogger.debug(userInfo: "end graph set \(type(of: view))")
        }
        switch view {
        case let tuple as ContainerViewGraphSetAcceptable:
            return tuple.accept(visitor: self)
        case let modifier as ViewGraphSetAttributeAcceptable:
            return modifier.accept(visitor: self)
        case let view as ViewGraphSetAcceptable:
            return view.accept(visitor: self)
        case let _view as _View:
            return _view._wrappedViewForBuildGraph.accept(visitor: self)
        }
    }

}
