//
//  EmptyView.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/06.
//

import Foundation

@frozen public struct EmptyView {
    @inlinable public init() { }
}

extension EmptyView : View {
    public typealias Body = Never
}

extension EmptyView: ViewContentAcceptable {
    internal func accept(visitor: ViewContentVisitor) -> ViewContentVisitor.VisitResult {
        
    }
}

extension EmptyView: Primitive { }
extension EmptyView: Rendable { }
extension EmptyView: ViewGraphSetAcceptable {
    internal func accept(visitor: ViewGraphSetVisitor) -> ViewGraph {
        _accept(visitor: visitor)
    }
}

extension EmptyView: HasIntrinsicContentSize {
    func intrinsicContentSize(viewGraph: ViewGraph, visitor: ViewSetRectVisitor) -> Size {
        return .zero
    }
}

extension EmptyView: ViewSetContentSizeVisitorAcceptable {
    func accept(visitor: ViewSetContentSizeVisitor) {
        visitor.current!.contentSize = .zero
    }
}
extension EmptyView: ViewSetPositionVisitorAcceptable {
    func accept(visitor: ViewSetPositionVisitor) {
        visitor.current!.rect.origin = .zero
    }
}
extension EmptyView: ViewSetSizeVisitorAcceptable {
    func accept(visitor: ViewSetSizeVisitor) {
        visitor.current!.rect.size = .zero
    }
}
