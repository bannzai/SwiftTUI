//
//  PaddingModifier.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2020/03/28.
//

import Foundation

@frozen public enum Edge: Swift.Int8, Swift.CaseIterable {
    case top, leading, bottom, trailing
    @frozen public struct Set: Swift.OptionSet {
        public typealias Element = Edge.Set
        public let rawValue: Swift.Int8
        public init(rawValue: Swift.Int8) {
            self.rawValue = rawValue
        }
        public init(_ e: Edge) {
            self.init(rawValue: e.rawValue)
        }
        public static let top: Edge.Set = Element(rawValue: 1 << 0)
        public static let leading: Edge.Set = Element(rawValue: 1 << 1)
        public static let bottom: Edge.Set = Element(rawValue: 1 << 2)
        public static let trailing: Edge.Set = Element(rawValue: 1 << 3)
        public static let all: Edge.Set = [.top, .leading, .bottom, .trailing]
        public static let horizontal: Edge.Set = [.leading, .trailing]
        public static let vertical: Edge.Set = [.top, .bottom]
    }
}

@frozen public struct EdgeInsets : Swift.Equatable {
    public var top: PhysicalDistance
    public var leading: PhysicalDistance
    public var bottom: PhysicalDistance
    public var trailing: PhysicalDistance
    @inlinable public init(top: PhysicalDistance, leading: PhysicalDistance, bottom: PhysicalDistance, trailing: PhysicalDistance) {
        self.top = top
        self.leading = leading
        self.bottom = bottom
        self.trailing = trailing
    }
    @inlinable public init() {
        self.init(top: 0, leading: 0, bottom: 0, trailing: 0)
    }
    public static func == (a: EdgeInsets, b: EdgeInsets) -> Swift.Bool {
        a.top == b.top && a.leading == b.leading && a.bottom == b.bottom && a.trailing == b.trailing
    }
}

extension EdgeInsets {
    @usableFromInline
    internal init(_all: PhysicalDistance) {
        self.init(top: _all, leading: _all, bottom: _all, trailing: _all)
    }
}

internal let defaultPadding = 1
@frozen public struct _PaddingLayout: ViewModifier {
    public var edges: Edge.Set
    public var insets: EdgeInsets?
    @inlinable public init(edges: Edge.Set = .all, insets: EdgeInsets?) {
        self.edges = edges
        self.insets = insets
    }
    public typealias Body = Swift.Never
}

internal extension _PaddingLayout {
    func height(from height: PhysicalDistance) -> PhysicalDistance {
        if let insets = insets {
            return height + insets.top + insets.bottom
        }
        
        var height = height
        if edges.contains(.top) { height = height + defaultPadding }
        if edges.contains(.bottom) { height = height + defaultPadding }
        return height
    }
    func width(from width: PhysicalDistance) -> PhysicalDistance {
        if let insets = insets {
            return width + insets.leading + insets.trailing
        }
        
        var width = width
        if edges.contains(.leading) { width = width + defaultPadding }
        if edges.contains(.trailing) { width = width + defaultPadding }
        return width
    }
}

extension View {
    @inlinable public func padding(_ insets: EdgeInsets) -> some View {
        return modifier(_PaddingLayout(insets: insets))
    }
    
    @inlinable public func padding(_ edges: Edge.Set = .all, _ length: PhysicalDistance? = nil) -> some View {
        let insets = length.map { EdgeInsets(_all: $0) }
        return modifier(_PaddingLayout(edges: edges, insets: insets))
    }
    
    @inlinable public func padding(_ length: PhysicalDistance) -> some View {
        return padding(.all, length)
    }
}
