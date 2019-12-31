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
    
    public var _baseProperty: _ViewBaseProperties? = _ViewBaseProperties()
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
    func visit<View: SwiftTUI.View, Visitor: ViewContentVisitor>(view: View, visitor: Visitor) -> Visitor.VisitResult {
        // TODO:
    }
    
    func visit<View: SwiftTUI.View, Visitor: ViewSizeVisitor>(view: View, visitor: Visitor, with argument: ViewSizeVisitor.Argument) -> Visitor.VisitResult {
        var proposedSize = argument.proposedSize
        width.map { width in proposedSize.width = min(width, proposedSize.width) }
        height.map { height in proposedSize.height = min(height, proposedSize.height) }

        var size = visitor.visit(view, with: argument.change(proposedSize: proposedSize))
        width.map { width in size.width = min(width, size.width) }
        height.map { height in size.height = min(height, size.height) }
        _baseProperty?.rect.size = size
        return size
    }
}
