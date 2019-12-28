//
//  ViewDimensions.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/12.
//

import Foundation


public struct ViewDimensions {
    public var width: PhysicalDistance
    public var height: PhysicalDistance
    
    public subscript(guide: HorizontalAlignment) -> PhysicalDistance {
        fatalError("TODO: Implement")
    }
    public subscript(guide: VerticalAlignment) -> PhysicalDistance {
        fatalError("TODO: Implement")
    }
    public subscript(explicit guide: HorizontalAlignment) -> PhysicalDistance? {
        fatalError("TODO: Implement")
    }
    public subscript(explicit guide: VerticalAlignment) -> PhysicalDistance? {
        fatalError("TODO:")
    }
}

extension ViewDimensions: Equatable {
    public static func == (lhs: ViewDimensions, rhs: ViewDimensions) -> Bool {
        lhs.width == rhs.width && lhs.height == rhs.height
    }
}
