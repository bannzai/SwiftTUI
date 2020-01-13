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
    public internal(set) subscript(explicit guide: HorizontalAlignment) -> PhysicalDistance? {
        get { extract(explicit: guide.key) }
        set { set(guide: guide, value: newValue ?? 0) }
    }
    public internal(set) subscript(explicit guide: VerticalAlignment) -> PhysicalDistance? {
        get { extract(explicit: guide.key) }
        set { set(guide: guide, value: newValue ?? 0) }
    }
    
    private func extract(explicit key: AlignmentKey) -> PhysicalDistance? {
        explicitContainer.container[key]
    }
}

extension ViewDimensions {
    internal func set(guide: VerticalAlignment, value: PhysicalDistance) {
        // FIXME: Correct behavior is not known even in SwiftUI
        let childValue = graph
            .children
            .map ({ $0.dimensions })
            .compactMap({ dimensions in dimensions[explicit: guide] })
            .first
        switch childValue {
        case nil:
            guide.id._combineExplicit(childValue: value, into: &explicitContainer.container[guide.key])
        case .some(let childValue):
            guide.id._combineExplicit(childValue: childValue, into: &explicitContainer.container[guide.key])
        }
    }
    internal func set(guide: HorizontalAlignment, value: PhysicalDistance) {
        // FIXME: Correct behavior is not known even in SwiftUI
        let childValue = graph
            .children
            .map ({ $0.dimensions })
            .compactMap({ dimensions in dimensions[explicit: guide] })
            .first
        switch childValue {
        case nil:
            guide.id._combineExplicit(childValue: value, into: &explicitContainer.container[guide.key])
        case .some(let childValue):
            guide.id._combineExplicit(childValue: childValue, into: &explicitContainer.container[guide.key])
        }
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
