//
//  Alignment.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/11.
//

import Foundation

public struct VerticalAlignment {
    internal let id: AlignmentID.Type
    public init(_ id: AlignmentID.Type) {
        self.id = id
    }
    
    @usableFromInline
    internal let key: AlignmentKey = AlignmentKey(bits: #line) // TODO: Implement
    public static func == (lhs: VerticalAlignment, rhs: VerticalAlignment) -> Swift.Bool {
        lhs.key == rhs.key
    }
}

extension VerticalAlignment {
    private enum TopAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> PhysicalDistance {
            // TODO: Implement
            return 0
        }
    }
    private enum CenterAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> PhysicalDistance {
            // TODO: Implement
            return context.height / 2
        }
    }
    private enum BottomAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> PhysicalDistance {
            // TODO: Implement
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
}
