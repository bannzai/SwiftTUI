//
//  ViewDimensions.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/12.
//

import Foundation


public struct ViewDimensions {
    class ExplicitContainer {
        fileprivate var horizontal: [HorizontalAlignment: PhysicalDistance] = [:]
        //    private var verticalExplicit: [VerticalAlignment: PhysicalDistance] = [:]
    }

    internal var _width: PhysicalDistance? = nil
    internal var _height: PhysicalDistance? = nil
    
    public var width: PhysicalDistance { _width ?? 0 }
    public var height: PhysicalDistance { _height ?? 0 }
    
    private var childValue: PhysicalDistance {
        fatalError("TODO:")
    }
    private var level: Int {
        fatalError("TODO:")
    }
    
    private var explicitContainer = ExplicitContainer()

    public subscript(guide: HorizontalAlignment) -> PhysicalDistance {
        guide.id.defaultValue(in: self)
    }
    public subscript(guide: VerticalAlignment) -> PhysicalDistance {
        guide.id.defaultValue(in: self)
    }
    public subscript(explicit guide: HorizontalAlignment) -> PhysicalDistance? {
        var horizontal: PhysicalDistance? = explicitContainer.horizontal[guide] 
        guide.id._combineExplicit(childValue: childValue, level, into: &horizontal)
        explicitContainer.horizontal[guide] = horizontal
        return horizontal
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
