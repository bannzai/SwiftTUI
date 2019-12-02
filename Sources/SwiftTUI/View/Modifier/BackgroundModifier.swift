//
//  BackgroundModifier.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/18.
//

import Foundation

@frozen public struct _BackgroundModifier<Background> : ViewModifier where Background : View {
    public var background: Background
    @inlinable public init(background: Background) {
        self.background = background
    }
    public typealias Body = Swift.Never
}

extension _BackgroundModifier : Swift.Equatable where Background : Swift.Equatable {
    public static func == (a: _BackgroundModifier<Background>, b: _BackgroundModifier<Background>) -> Swift.Bool {
        a.background == b.background
    }
}

extension View {
    @inlinable public func background<Background>(_ background: Background) -> some View where Background : View {
        return modifier(_BackgroundModifier(background: background))
    }
}

extension _BackgroundModifier: _ViewModifier {
    static var _keyPaths: Set<PartialKeyPath<_ViewBaseProperties>> {
        [\_ViewBaseProperties.backgroundColor]
    }
    
    func modify<V: View>(view: V) -> V {
        for keyPath in _BackgroundModifier._keyPaths {
            switch background {
            case let color as Color:
                let keyPath: ReferenceWritableKeyPath<_ViewBaseProperties, Color> = writableKeyPath(from: keyPath)
                view._baseProperty?[keyPath: keyPath] = color
            case _:
                break
            }
        }
        return view
    }
}
