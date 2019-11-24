//
//  HorizontalAlignment.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/12.
//

import Foundation

public struct HorizontalAlignment {
    internal let id: AlignmentID.Type
    @usableFromInline
    internal let key: AlignmentKey
    
    public init(_ id: AlignmentID.Type) {
        self.id = id
        let type: Any.Type = id
        let pointer = unsafeBitCast(type, to: UnsafePointer<StructTypeMetadata>.self).pointee.typeDescriptor.pointee.name.advanced()
        self.key = AlignmentKey(bits: UInt(pointer.pointee))
    }
    public static func == (lhs: HorizontalAlignment, rhs: HorizontalAlignment) -> Swift.Bool {
        lhs.id == rhs.id
    }
}

extension HorizontalAlignment {
    private enum LeadingAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> PhysicalDistance {
            // TODO: Implement
            return 0
        }
    }
    private enum CenterAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> PhysicalDistance {
            // TODO: Implement
            return context.width / 2
        }
    }
    private enum TrailingAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> PhysicalDistance {
            // TODO: Implement
            return context.width
        }
    }
    public static let leading: HorizontalAlignment = HorizontalAlignment(LeadingAlignment.self)
    public static let center: HorizontalAlignment = HorizontalAlignment(CenterAlignment.self)
    public static let trailing: HorizontalAlignment = HorizontalAlignment(TrailingAlignment.self)
}

extension HorizontalAlignment: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(key)
    }
}
