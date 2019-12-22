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
}

extension _BorderModifier: Swift.Equatable where Target: Swift.Equatable {
    public static func == (lhs: _BorderModifier<Target>, rhs: _BorderModifier<Target>) -> Swift.Bool {
        lhs.target == rhs.target
    }
}
extension View {
    @inlinable public func border<S>(color: Color, direction: Border.DirectionType = .default) -> some View {
        modifier(_BorderModifier(target: self, border: Border(color: color, directionType: direction)))
    }
}

extension _BorderModifier: _ViewModifier {
    func visit<View: SwiftTUI.View, Visitor: ViewContentVisitor>(view: View, visitor: Visitor) {
        // TODO:
    }
}


