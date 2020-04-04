//
//  BorderModifier.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/12/15.
//

import Foundation

public struct Border {
    public let color: Color
    public let delimiter: String?
    public let width: PhysicalDistance
    public let directionType: DirectionType

    public init(color: Color?, delimiter: String?, width: PhysicalDistance, directionType: DirectionType) {
        self.color = color ?? Style.Color.border.color
        self.delimiter = delimiter
        self.width = width
        self.directionType = directionType
    }
    
    public enum DirectionType: Int8 {
        case top, left, right, bottom
        case all
        
        public static let `default`: DirectionType = .all
    }
}

@frozen public struct _BorderModifier: ViewModifier {
    @usableFromInline internal let border: Border
    
    public init(border: Border) {
        self.border = border
    }
    public typealias Body = Swift.Never
}

extension View {
    @inlinable public func border(color: Color? = nil, delimiter: String? = nil, width: PhysicalDistance = 1, direction: Border.DirectionType = .default) -> some View {
        modifier(_BorderModifier(border: Border(color: color, delimiter: delimiter, width: width, directionType: direction)))
    }
}
