//
//  VariadicView.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/15.
//

import Foundation

public enum VariadicView {
    public typealias Root = _VariadicView_Root
    @frozen public struct Tree<Root, Content>: View where Root : _VariadicView_Root, Content: View {
        public var root: Root
        public var content: Content
        @inlinable internal init(root: Root, content: Content) {
            self.root = root
            self.content = content
        }
        @inlinable public init(_ root: Root, @ViewBuilder content: () -> Content) {
            self.root = root
            self.content = content()
        }
        public typealias Body = Never
    }
}

public protocol _VariadicView_Root {
    // TODO:
    static var _viewListOptions: ViewVisitorListOption { get }
}

extension VariadicView.Tree: ViewContentAcceptable {
    internal func accept(visitor: ViewContentVisitor) -> ViewContentVisitor.VisitResult {
        let option = Root._viewListOptions
        
        if let vertical = root as? _VStackLayout {
            let keepAlignment = visitor.containerAlignment
            visitor.containerAlignment.horizontal = vertical.alignment
            visitor.visit(content, with: option)
            visitor.containerAlignment = keepAlignment
            return
        }
        
        if let horizontal = root as? _HStackLayout {
            let keepAlignment = visitor.containerAlignment
            visitor.containerAlignment.vertical = horizontal.alignment
            visitor.visit(content, with: option)
            visitor.containerAlignment = keepAlignment
            return
        }
        
        fatalError("Unexpected variadic tree type of \(type(of:root))")
    }
}

extension VariadicView.Tree: ViewSizeAcceptable {
    internal func accept(visitor: ViewSizeVisitor, with argument: ViewSizeVisitor.Argument) -> ViewSizeVisitor.VisitResult {
        let option = Root._viewListOptions
        
        if let vertical = root as? _VStackLayout {
            let keepAlignment = visitor.containerAlignment
            visitor.containerAlignment.horizontal = vertical.alignment
            let argument = ViewSizeVisitor.Argument(listOption: option, space: vertical.spacing ?? ViewVisitorListOption.vertical.defaultSpace, proposedSize: argument.proposedSize)
            let size = visitor.visit(content, with: argument)
            visitor.containerAlignment = keepAlignment
            return size
        }
        
        if let horizontal = root as? _HStackLayout {
            let keepAlignment = visitor.containerAlignment
            visitor.containerAlignment.vertical = horizontal.alignment
            let argument = ViewSizeVisitor.Argument(listOption: option, space: horizontal.spacing ?? ViewVisitorListOption.horizontal.defaultSpace, proposedSize: argument.proposedSize)
            let size = visitor.visit(content, with: argument)
            visitor.containerAlignment = keepAlignment
            return size
        }
        
        fatalError("Unexpected variadic tree type of \(type(of:root))")
    }
}

