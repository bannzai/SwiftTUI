//
//  FrameModifier.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/24.
//

import Foundation

@frozen public struct _FrameLayout: ViewModifier {
    internal let width: PhysicalDistance?
    internal let height: PhysicalDistance?
    internal let alignment: Alignment
    public typealias Body = Swift.Never
    
    @usableFromInline
    internal init(width: PhysicalDistance?, height: PhysicalDistance?, alignment: Alignment) {
        self.width = width
        self.height = height
        self.alignment = alignment
    }
}

internal extension _FrameLayout {
    func modifySize(for graph: ViewGraph, visitor: ViewSetRectVisitor) {
        assert(!graph.rendableChildren.isEmpty, "it is necessary about rendable view")
        graph.rendableChildren.forEach { baseGraph in
            baseGraph.setProposedSizeIfFirst(Size(width: width ?? graph.proposedSize.width, height: height ?? graph.proposedSize.height))
            baseGraph.acceptSize(visitor: visitor)

            let _width = width ?? baseGraph.rect.size.width
            let _height = height ?? baseGraph.rect.size.height
            graph.rect.size.width = max(graph.rect.size.width, _width)
            graph.rect.size.height = max(graph.rect.size.height, _height)
        }
    }
}

extension _FrameLayout: Rendable { }
extension _FrameLayout: Primitive { }
extension _FrameLayout: ContainerViewType { }
extension _FrameLayout: ViewContentAcceptable {
    func accept(visitor: ViewContentVisitor) {
        // NOTE: escape to reach ViewModifier.Body is Never
    }
}

extension _FrameLayout: ViewSetContentSizeVisitorAcceptable {
    func accept(visitor: ViewSetContentSizeVisitor) {
        let graph = visitor.current!
        assert(graph.children.count == 1, "it should want one child")
        let child = graph.children[0]

        let _width = width ?? child.contentSize.width
        let _height = height ?? child.contentSize.height
        graph.contentSize = Size(width: _width, height: _height)
    }
}

extension _FrameLayout: ViewSetPositionVisitorAcceptable {
    func accept(visitor: ViewSetPositionVisitor) {
        let graph = visitor.current!
        assert(graph.children.count == 1, "it should want one child")
        let child = graph.children[0]
        
        let containerX = extractAlignmentXValue(graph: graph, alignment: child.alignment.horizontal)
        let x = extractAlignmentXValue(graph: child, alignment: child.alignment.horizontal)
        child.rect.origin.x = containerX - x
        
        let containerY = extractAlignmentYValue(graph: graph, alignment: child.alignment.vertical)
        let y = extractAlignmentYValue(graph: child, alignment: child.alignment.vertical)
        child.rect.origin.y = containerY - y
    }
}

extension _FrameLayout: ViewSetSizeVisitorAcceptable {
    func accept(visitor: ViewSetSizeVisitor) {
        let graph = visitor.current!
        assert(graph.children.count == 1, "it should want one child")
        let child = graph.children[0]
        
        child.proposedSize.width = min(graph.contentSize.width, graph.proposedSize.width)
        visitor.visit(child)
        
        let _width = width ?? child.rect.size.width
        let _height = height ?? child.rect.size.height
        graph.rect.size = Size(width: _width, height: _height)
    }
}

extension View {
    @inlinable public func frame(width: PhysicalDistance? = nil, height: PhysicalDistance? = nil, alignment: Alignment = .center) -> some View {
        modifier(
            _FrameLayout(width: width, height: height, alignment: alignment)
        )
    }
    
    @available(*, deprecated, message: "Please pass one or more parameters.")
    @inlinable public func frame() -> some View {
          return frame(width: nil, height: nil, alignment: .center)
      }
}
