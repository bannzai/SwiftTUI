//
//  ViewGraphImpl.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2020/04/08.
//

import Foundation

public final class ViewGraphImpl<View: SwiftTUI.View>: ViewGraph {
    internal typealias ViewType = View
    
    internal let view: View
    internal init(view: View) {
        self.view = view
    }
    
    public var body: some SwiftTUI.View {
        view.body
    }
    
    override var anyView: Any {
        view
    }
}

extension ViewGraph: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    public static func == (lhs: ViewGraph, rhs: ViewGraph) -> Swift.Bool {
        lhs.identifier == rhs.identifier
    }
}


extension ViewGraph: ViewContentAcceptable {
    func accept(visitor: ViewContentVisitor) {
        let keepCurrent = visitor.current
        visitor.current = self
        defer {
            visitor.current = keepCurrent
            children.forEach { $0.accept(visitor: visitor) }
            visitor.driver.restoreBackgroundColor()
        }
        
        if renderMarker.isMarked(graph: self) {
            return
        }
        renderMarker.mark(graph: self)
        
        sharedCursor.moveTo(point: positionToWindow())
        if let content = anyView as? ViewContentAcceptable {
            content.accept(visitor: visitor)
        }
    }
}
