//
//  ViewModifier.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/28.
//

import Foundation

public struct _ViewModifier_Content<Modifier>: View where Modifier: ViewModifier {
    public typealias Body = Swift.Never
}


public protocol ViewModifier {
    associatedtype Body : View
    func body(content: Self.Content) -> Self.Body
    typealias Content = _ViewModifier_Content<Self>
}

extension ViewModifier where Body == Never {
    public func body(content: Self.Content) -> Self.Body {
        fatalError("body is never. received argument \(content)")
    }
}

internal protocol _ViewModifier {
    func visit<View: SwiftTUI.View, Visitor: ViewContentVisitor>(view: View, visitor: Visitor) -> Visitor.VisitResult
    func visit<View: SwiftTUI.View, Visitor: ViewSizeVisitor>(view: View, visitor: Visitor) -> Visitor.VisitResult
}

internal protocol _RestoreableViewModifier {
    func restore<View: SwiftTUI.View, Visitor: ViewContentVisitor>(view: View, visitor: Visitor) -> Visitor.VisitResult 
}
