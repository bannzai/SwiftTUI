//
//  Graph.swift
//  SwiftTUITests
//
//  Created by Yudai.Hirose on 2020/04/11.
//

import XCTest
@testable import SwiftTUI

func prepareSizedGraph<T: View>(view: T, viewListOption: ViewVisitorListOption = .vertical) -> ViewGraph {
    (sharedCursor as? TestCursor)?.reset()
    
    let graphVisitor = ViewGraphSetVisitor()
    let graph = graphVisitor.visit(view)
    graph.listType = viewListOption
    
    // FIXME: Remove Size Visitor??
    let sizeVisitor = ViewSetRectVisitor()
    _ = sizeVisitor.visit(graph)
    
    return graph
}

func prepareViewGraph<T: View>(view: T) -> ViewGraph {
    let graphVisitor = ViewGraphSetVisitor()
    let graph = graphVisitor.visit(view)
    return graph
}

