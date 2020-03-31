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
     func sideEffect(for paddingGraph: ViewGraph, visitor: ViewSetRectVisitor) {
        let horizontalLength = self.horizontalLength()
        let verticalLength = self.verticalLength()
        
        visitor.proposedSize.width -= horizontalLength
        visitor.proposedSize.height -= verticalLength

        let baseGraph = paddingGraph.extractRendableChlid()
        baseGraph.accept(visitor: visitor)
        
        paddingGraph.rect.size.width = baseGraph.rect.size.width + horizontalLength
        paddingGraph.rect.size.height = baseGraph.rect.size.height + verticalLength
        
        if edges.contains(.leading) { baseGraph.rect.origin.x = (insets?.leading ?? defaultPadding) }
        if edges.contains(.top) { baseGraph.rect.origin.y = (insets?.top ?? defaultPadding) }
    }
    private func verticalLength() -> PhysicalDistance {
        var length = 0
        if edges.contains(.top) { length = length + (insets?.top ?? defaultPadding) }
        if edges.contains(.bottom) { length = length + (insets?.bottom ?? defaultPadding) }
        return length
    }
    private func horizontalLength() -> PhysicalDistance {
        var length = 0
        if edges.contains(.leading) { length = length + (insets?.leading ?? defaultPadding) }
        if edges.contains(.trailing) { length = length + (insets?.trailing ?? defaultPadding) }
        return length
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
