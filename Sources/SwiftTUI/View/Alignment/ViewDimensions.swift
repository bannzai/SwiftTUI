//
//  ViewDimensions.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/12.
//

import Foundation


public struct ViewDimensions {
    public var width: PhysicalDistance { graph.rect.size.width }
    public var height: PhysicalDistance { graph.rect.size.height }
    
    internal var size: Size { Size(width: width, height: height) }
    private var graph: ViewGraph
    internal init(graph: ViewGraph) {
        self.graph = graph
    }

    private var explicitContainer = ExplicitContainer()
    
    public subscript(guide: HorizontalAlignment) -> PhysicalDistance {
        guide.id.defaultValue(in: self)
    }
    public subscript(guide: VerticalAlignment) -> PhysicalDistance {
        guide.id.defaultValue(in: self)
    }
    public subscript(explicit guide: HorizontalAlignment) -> PhysicalDistance? {
        extract(explicit: guide.key)
    }
    public subscript(explicit guide: VerticalAlignment) -> PhysicalDistance? {
        extract(explicit: guide.key)
    }
    
    private func extract(explicit key: AlignmentKey) -> PhysicalDistance? {
        explicitContainer.container[key]
    }
}

extension ViewDimensions {
    internal func set(guide: VerticalAlignment, value: PhysicalDistance) {
        guard let childValue = graph
            .children
            .map ({ $0.dimensions })
            .compactMap({ dimensions in dimensions[explicit: guide] })
            .first
            else {
                return
        }
        guide.id._combineExplicit(childValue: childValue, into: &explicitContainer.container[guide.key])
    }
    internal func set(guide: HorizontalAlignment, value: PhysicalDistance) {
        guard let childValue = graph
            .children
            .map ({ $0.dimensions })
            .compactMap({ dimensions in dimensions[explicit: guide] })
            .first
            else {
                return
        }
        guide.id._combineExplicit(childValue: childValue, into: &explicitContainer.container[guide.key])
    }
}

extension ViewDimensions {
    fileprivate class ExplicitContainer {
        var container: [AlignmentKey: PhysicalDistance] = [:]
    }
}

extension ViewDimensions: Equatable {
    public static func == (lhs: ViewDimensions, rhs: ViewDimensions) -> Bool {
        lhs.width == rhs.width && lhs.height == rhs.height
    }
}
