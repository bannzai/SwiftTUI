//
//  BorderModifier.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/12/15.
//

import Foundation

@frozen public struct _BorderModifier<Target>: ViewModifier where Target: View {
    public let target: Target
    public let border: Border
    @inlinable public init(target: Target, border: Border) {
        self.target = target
        self.border = border
    }
    public typealias Body = Swift.Never
    
    internal var _baseProperty: _ViewBaseProperties = _ViewBaseProperties()
}

extension _BorderModifier: Swift.Equatable where Target: Swift.Equatable {
    public static func == (lhs: _BorderModifier<Target>, rhs: _BorderModifier<Target>) -> Swift.Bool {
        lhs.target == rhs.target
    }
}
extension View {
    @inlinable public func border<S>(color: Color, width: PhysicalDistance, direction: Border.DirectionType = .default) -> some View {
        modifier(_BorderModifier(target: self, border: Border(color: color, width: width, directionType: direction)))
    }
}

extension _BorderModifier: Primitive { }

extension _BorderModifier: _ViewModifier {
    func visit<View: SwiftTUI.View, Visitor: ViewContentVisitor>(view: View, visitor: Visitor) -> Visitor.VisitResult {
        // TODO:
    }
    
    func visit<View: SwiftTUI.View, Visitor: ViewSizeVisitor>(view: View, visitor: Visitor, with argument: ViewSizeVisitor.Argument) -> Visitor.VisitResult {
        var proposedSize = argument.proposedSize
        proposedSize.width -= border.width * 2
        proposedSize.height -= border.width * 2
        let contentSize = visitor.visit(view, with: argument.change(proposedSize: proposedSize))
        
        var size = contentSize
        size.width += border.width * 2
        size.height += border.width * 2
        _baseProperty.rect.size = size
        
        return size
    }
}


