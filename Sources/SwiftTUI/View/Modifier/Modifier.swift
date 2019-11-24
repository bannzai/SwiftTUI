//
//  Modifier.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/18.
//

import Foundation

@frozen public struct ModifiedContent<Content, Modifier> {
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

extension ModifiedContent: Acceptable where Content : View, Modifier : ViewModifier {
    public func accept<V>(visitor: V) -> V.VisitResult where V: Visitor {
        fatalError("\(#function) can not call. because Body is never")
    }
}

extension ModifiedContent: View where Content : View, Modifier : ViewModifier {
    public typealias Body = Swift.Never
}

extension View {
    @inlinable public func modifier<T>(_ modifier: T) -> ModifiedContent<Self, T> {
        return .init(content: self, modifier: modifier)
    }
}
