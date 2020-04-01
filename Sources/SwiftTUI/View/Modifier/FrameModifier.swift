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
    internal let alignment: Alignment?
    public typealias Body = Swift.Never
    
    internal var _baseProperty: _ViewBaseProperties = _ViewBaseProperties()
}

extension View {
    public func frame(width: PhysicalDistance? = nil, height: PhysicalDistance? = nil, alignment: Alignment? = nil) -> some View {
        modifier(
            _FrameLayout(width: width, height: height, alignment: alignment)
        )
    }
    
    public func frame() -> some View {
        frame(width: nil, height: nil)
    }
}
