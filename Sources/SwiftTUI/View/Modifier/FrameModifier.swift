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
    
    @usableFromInline
    internal init(width: PhysicalDistance?, height: PhysicalDistance?, alignment: Alignment) {
        self.width = width
        self.height = height
        self.alignment = alignment
    }
    
    internal var _baseProperty: _ViewBaseProperties = _ViewBaseProperties()
}

extension View {
    @inlinable public func frame(width: PhysicalDistance? = nil, height: PhysicalDistance? = nil, alignment: Alignment = .center) -> some View {
        modifier(
            _FrameLayout(width: width, height: height, alignment: alignment)
        )
    }
    
    @available(*, deprecated, message: "Please pass one or more parameters.")
    @inlinable public func frame() -> some View {
          return frame(width: nil, height: nil, alignment: .center)
      }
}
