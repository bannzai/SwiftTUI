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
