//
//  FrameModifier.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/24.
//

import Foundation

@frozen public struct _FrameLayout: ViewModifier {
    internal let width: PhysicalDistance?
    internal let height: PhysicalDistance?
    public typealias Body = Swift.Never
}

extension View {
    public func frame(width: PhysicalDistance? = nil, height: PhysicalDistance? = nil) -> some View {
        modifier(
            _FrameLayout(width: width, height: height)
        )
    }
    
    public func frame() -> some View {
        frame(width: nil, height: nil)
    }
}

extension _FrameLayout: _ViewModifier {
    static var _keyPaths: Set<PartialKeyPath<_ViewBaseProperties>> {
        [\_ViewBaseProperties.rect?.size.width, \_ViewBaseProperties.rect?.size.height]
    }
    
    func modify<V: View>(view: V) -> V {
        _FrameLayout._keyPaths.forEach { keyPath in
            switch keyPath {
            case \_ViewBaseProperties.rect?.size.width:
                view._baseProperty?[keyPath: writableKeyPath(from: keyPath)] = width
            case \_ViewBaseProperties.rect?.size.height:
                view._baseProperty?[keyPath: writableKeyPath(from: keyPath)] = height
            case _:
                fatalError("Unexpected pattern keyPath \(keyPath), in _FrameLayout")
            }
        }
        return view
    }
}
