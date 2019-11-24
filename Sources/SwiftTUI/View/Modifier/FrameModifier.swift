//
//  FrameModifier.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/24.
//

import Foundation

@frozen public struct _FrameLayout: ViewModifier {
    internal let width: CoreGraphics.CGFloat?
    internal let height: CoreGraphics.CGFloat?
    internal let alignment: Alignment
    
    @usableFromInline
    internal init(width: CoreGraphics.CGFloat?, height: CoreGraphics.CGFloat?, alignment: Alignment) {
        self.width = width
        self.height = height
        self.alignment = alignment
    }
    public typealias Body = Swift.Never
    
    // TODO:
//    public typealias AnimatableData = EmptyAnimatableData
}


@available(OSX 10.15.0, *)
extension View {
    @inlinable public func frame(width: CoreGraphics.CGFloat? = nil, height: CoreGraphics.CGFloat? = nil, alignment: Alignment = .center) -> some View {
        return modifier(
            _FrameLayout(width: width, height: height, alignment: alignment))
    }
    
    @inlinable public func frame() -> some View {
        return frame(width: nil, height: nil, alignment: .center)
    }
}

