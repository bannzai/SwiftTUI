//
//  ViewDimensions.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/12.
//

import Foundation


public struct ViewDimensions {
    public internal(set) var width: PhysicalDistance
    public internal(set) var height: PhysicalDistance
    
    internal var size: Size { Size(width: width, height: height) }
    internal init() {
        self.width = 0
        self.height = 0
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
        var vertical: PhysicalDistance? = explicitContainer.vertical[guide]
        guide.id._combineExplicit(childValue: childValue, level, into: &vertical)
        explicitContainer.vertical[guide] = vertical
        return vertical
    }
}

extension ViewDimensions {
    class ExplicitContainer {
        fileprivate var horizontal: [HorizontalAlignment: PhysicalDistance] = [:]
        fileprivate var vertical: [VerticalAlignment: PhysicalDistance] = [:]
    }
    private var childValue: PhysicalDistance {
        fatalError("TODO:")
    }
    private var level: Int {
        fatalError("TODO:")
    }
}

extension ViewDimensions: Equatable {
    public static func == (lhs: ViewDimensions, rhs: ViewDimensions) -> Bool {
        lhs.width == rhs.width && lhs.height == rhs.height
    }
}
