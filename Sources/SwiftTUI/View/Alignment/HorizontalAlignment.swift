//
//  HorizontalAlignment.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/12.
//

import Foundation

public struct HorizontalAlignment {
    private let id: AlignmentID.Type
    public init(_ id: AlignmentID.Type) {
        self.id = id
    }
    @usableFromInline
    internal let key: AlignmentKey = AlignmentKey(bits: #line)
    public static func == (lhs: HorizontalAlignment, rhs: HorizontalAlignment) -> Swift.Bool {
        lhs.key == rhs.key
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
