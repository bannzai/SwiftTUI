//
//  View.swift
//  Demo
//
//  Created by Yudai.Hirose on 2019/10/22.
//

import Foundation

/// A piece of user interface.
///
/// You create custom views by declaring types that conform to the `View`
/// protocol. Implement the required `body` property to provide the content
/// and behavior for your custom view.
public protocol View: Acceptable {

    /// The type of view representing the body of this view.
    ///
    /// When you create a custom view, Swift infers this type from your
    /// implementation of the required `body` property.
    associatedtype Body : View

    /// Declares the content and behavior of this view.
    var body: Self.Body { get }
}

extension View {
    public func accept<V>(visitor: V) -> V.VisitoResult where V: Visitor {
        visitor.visit(body)
    }
}
