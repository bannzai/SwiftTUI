//
//  ModifierContent.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/28.
//

import Foundation

@frozen public struct ModifiedContent<Content, Modifier> where Content: View, Modifier: ViewModifier {
  public var content: Content
  public var modifier: Modifier
  @inlinable public init(content: Content, modifier: Modifier) {
        self.content = content
        self.modifier = modifier
    }
}

extension ModifiedContent : Swift.Equatable where Content : Swift.Equatable, Modifier : Swift.Equatable {
    public static func == (lhs: ModifiedContent<Content, Modifier>, rhs: ModifiedContent<Content, Modifier>) -> Swift.Bool {
        lhs.content == rhs.content
    }
}

extension ModifiedContent: ViewAcceptable {
    public func accept<V: AnyViewVisitor>(visitor: V) -> V.VisitResult {
        var result = V.VisitResult.empty()
        if let _modifier = modifier as? _ViewModifier {
            result += visitor.visit(_modifier.modify(view: content))
        } else {
            let modifiedContent = modifier.body(content: _ViewModifier_Content<Modifier>())
            result += visitor.visit(modifiedContent)
        }
        if let modifiedContent = modifier as? ModifiedContent {
            result += visitor.visit(modifiedContent)
        }
        result += visitor.visit(content)
        return result
    }
}

internal extension ModifiedContent {
    mutating func modifed<Value>(keyPath: WritableKeyPath<Content, Value>, value: Value) {
        content[keyPath: keyPath] = value
    }
}

extension ModifiedContent: View {
    public typealias Body = Swift.Never
    public var _baseProperty: _ViewBaseProperties? { nil }
}

extension View {
    @inlinable public func modifier<T: ViewModifier>(_ modifier: T) -> ModifiedContent<Self, T> {
        return .init(content: self, modifier: modifier)
    }
}
