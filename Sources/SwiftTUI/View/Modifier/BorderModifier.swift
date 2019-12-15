//
//  BorderModifier.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/12/15.
//

import Foundation

@frozen public struct _BorderModifier<Target>: ViewModifier where Target: View {
    public let target: Target
    public let color: Color
    @inlinable public init(target: Target, color: Color) {
        self.target = target
        self.color = color
    }
    public typealias Body = Swift.Never
}

extension _BorderModifier: Swift.Equatable where Target: Swift.Equatable {
    public static func == (lhs: _BorderModifier<Target>, rhs: _BorderModifier<Target>) -> Swift.Bool {
        lhs.target == rhs.target
    }
}
extension View {
    @inlinable public func border<S>(color: Color) -> some View {
        modifier(_BorderModifier(target: self, color: color))
    }
}

extension _BorderModifier: _ViewModifier {
    static var _keyPaths: Set<PartialKeyPath<_ViewBaseProperties>> {
        [\_ViewBaseProperties.border.color]
    }
    
    func modify<V: View>(view: V) -> V {
        for keyPath in _BorderModifier._keyPaths {
            switch keyPath {
            case \_ViewBaseProperties.border.color:
                let keyPath: ReferenceWritableKeyPath<_ViewBaseProperties, Color> = writableKeyPath(from: keyPath)
                view._baseProperty?[keyPath: keyPath] = color
            case _:
                fatalError("Unexpected pattern keypath of \(keyPath)")
            }
        }
        return view
    }
}


