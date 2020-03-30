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
    internal var graph: ViewGraph!
    internal init() {
        
    }

    private var explicitContainer = ExplicitContainer()
    
    public subscript(guide: HorizontalAlignment) -> PhysicalDistance {
        guide.id.defaultValue(in: self)
    }
    public subscript(guide: VerticalAlignment) -> PhysicalDistance {
        guide.id.defaultValue(in: self)
    }
    public internal(set) subscript(explicit guide: HorizontalAlignment) -> PhysicalDistance? {
        get { self[explicit: guide.key] }
        set { set(guide: guide, value: newValue ?? 0) }
    }
    public internal(set) subscript(explicit guide: VerticalAlignment) -> PhysicalDistance? {
        get { self[explicit: guide.key] }
        set { set(guide: guide, value: newValue ?? 0) }
    }
    
    internal subscript(explicit key: AlignmentKey) -> PhysicalDistance? {
        get {
            if let value = explicitContainer.container[key] {
                return value
            }
            return nil
        }
        set {
            set(key: key, value: newValue ?? 0)
        }
    }
}

extension ViewDimensions {
    func set(key: AlignmentKey, value: PhysicalDistance) {
        explicitContainer.container[key] = value
    }
    private func set(guide: VerticalAlignment, value: PhysicalDistance) {
        set(key: guide.key, value: value)
    }
    private func set(guide: HorizontalAlignment, value: PhysicalDistance) {
        set(key: guide.key, value: value)
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
