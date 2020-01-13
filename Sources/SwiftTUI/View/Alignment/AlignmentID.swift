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

fileprivate let noSpecifyLevel = 0
fileprivate let undefinedValue: PhysicalDistance? = nil
extension AlignmentID {
    public static func _combineExplicit(childValue: PhysicalDistance, _ n: Swift.Int, into parentValue: inout PhysicalDistance?) {
        // FIXME: Myabe incorrect
        if parentValue == undefinedValue {
            parentValue = childValue
            return
        }
    }
    
    internal static func _combineExplicit(childValue: PhysicalDistance, into parentValue: inout PhysicalDistance?) {
        _combineExplicit(childValue: childValue, noSpecifyLevel, into: &parentValue)
    }
}

