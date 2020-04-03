//
//  BorderModifier.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/12/15.
//

import Foundation

public let defaultBorderWidth: PhysicalDistance = 1
public struct Border {
    internal var color: Color
    internal var width: PhysicalDistance
    internal var directionType: DirectionType
    
    public init(color: Color, width: PhysicalDistance, directionType: DirectionType) {
        self.color = color
        self.width = width
        self.directionType = directionType
    }
    
    public enum DirectionType: Int8 {
        case top, left, right, bottom
        case all
        
        public static let `default`: DirectionType = .all
    }
}

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
    @inlinable public func border<S>(color: Color, width: PhysicalDistance, direction: Border.DirectionType = .default) -> some View {
        modifier(_BorderModifier(target: self, border: Border(color: color, width: width, directionType: direction)))
    }
}
