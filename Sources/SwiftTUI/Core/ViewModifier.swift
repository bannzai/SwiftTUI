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
    static var _keyPaths: Set<PartialKeyPath<_ViewBaseProperties>> { get }
    func modify<V: View>(view: V) -> V
}

extension _ViewModifier {
    func writableKeyPath<Value>(from keyPath: PartialKeyPath<_ViewBaseProperties>) -> ReferenceWritableKeyPath<_ViewBaseProperties, Value> {
        keyPath as! ReferenceWritableKeyPath<_ViewBaseProperties, Value>
    }
}
