//
//  Alignment.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/11.
//

import Foundation

public struct VerticalAlignment {
    internal let id: AlignmentID.Type
    @usableFromInline
    internal let key: AlignmentKey
    
    public init(_ id: AlignmentID.Type) {
        self.id = id
        let type: Any.Type = id
        let pointer = unsafeBitCast(type, to: UnsafePointer<StructTypeMetadata>.self).pointee.typeDescriptor.pointee.name.advanced()
        self.key = AlignmentKey(bits: UInt(pointer.pointee))
    }
    public static func == (lhs: VerticalAlignment, rhs: VerticalAlignment) -> Swift.Bool {
        lhs.id == rhs.id
    }
}

extension VerticalAlignment {
    private enum TopAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> PhysicalDistance {
            return 0
        }
    }
    private enum CenterAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> PhysicalDistance {
            return context.height / 2
        }
    }
    private enum BottomAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> PhysicalDistance {
            return context.height
        }
    }
    private enum FirstTextBaselineAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> PhysicalDistance {
            // TODO: Implement
            return 0
        }
    }
    private enum LastTextBaselineAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> PhysicalDistance {
            // TODO: Implement
            return 0
        }
    }
    public static let top: VerticalAlignment = VerticalAlignment(TopAlignment.self)
    public static let center: VerticalAlignment = VerticalAlignment(CenterAlignment.self)
    public static let bottom: VerticalAlignment = VerticalAlignment(BottomAlignment.self)
    public static let firstTextBaseline: VerticalAlignment = VerticalAlignment(FirstTextBaselineAlignment.self)
    public static let lastTextBaseline: VerticalAlignment = VerticalAlignment(LastTextBaselineAlignment.self)
    public static let `default`: VerticalAlignment = .center
}

extension VerticalAlignment: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(key)
    }
}
