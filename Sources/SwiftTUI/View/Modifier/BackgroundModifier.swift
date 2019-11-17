//
//  BackgroundModifier.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/18.
//

import Foundation

@frozen public struct _BackgroundModifier<Background>: ViewModifier where Background: View {
    public var background: Background
    @inlinable public init(background: Background) {
        self.background = background
    }
    public typealias Body = Swift.Never
    public func body(content: _ViewModifier_Content<_BackgroundModifier<Background>>) -> Never {
        fatalError("\(type(of: Self.self)) not have body")
    }
}

@available(OSX 10.15.0, *)
extension View {
    @inlinable public func background<Background>(_ background: Background) -> some View where Background: View {
        return modifier(
            _BackgroundModifier(background: background)
        )
    }
}
