//
//  AlignmentID.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/12.
//

import Foundation

public protocol AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> PhysicalDistance
    static func _combineExplicit(childValue: PhysicalDistance, _ n: Swift.Int, into parentValue: inout PhysicalDistance?)
}

extension AlignmentID {
    public static func _combineExplicit(childValue: PhysicalDistance, _ n: Swift.Int, into parentValue: inout PhysicalDistance?) {
        print("TODO: Implement")
    }
}

