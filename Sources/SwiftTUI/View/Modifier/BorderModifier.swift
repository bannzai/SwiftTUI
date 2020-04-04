//
//  BorderModifier.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/12/15.
//

import Foundation

extension Edge.Set {
    internal static let leadingTop: Edge.Set = [.leading, .top]
    internal static let trailingTop: Edge.Set = [.trailing, .bottom]
    internal static let leadingBottom: Edge.Set = [.leading, .top]
    internal static let trailingBottom: Edge.Set = [.trailing, .bottom]
    internal var defaultDelimiter: String {
        switch self {
        case .horizontal:
            return "-"
        case .vertical:
            return "|"
        case .leadingTop:
            return "┌"
        case .trailingTop:
            return "┐"
        case .leadingBottom:
            return "└"
        case .trailingBottom:
            return "┘"
        case _:
            fatalError("unexpected pattern default delimiter type for \(self)")
        }
    }
}

@frozen public struct _BorderModifier: ViewModifier {
    public let color: Color
    public let edges: Edge.Set
    public let insets: EdgeInsets?

    public init(color: Color?, edges: Edge.Set = .all, insets: EdgeInsets?) {
        self.color = color ?? Style.Color.border.color
        self.edges = edges
        self.insets = insets
    }
    
    public typealias Body = Swift.Never
}

extension _BorderModifier: Rendable { }
internal extension _BorderModifier {
    func modify(for graph: ViewGraph, visitor: ViewSetRectVisitor) {
        let horizontalLength = self.horizontalLength()
        let verticalLength = self.verticalLength()
        
        visitor.proposedSize.width -= horizontalLength
        visitor.proposedSize.height -= verticalLength
        
        assert(graph.extractRendableChlid() != nil, "it is necessary about rendable view")
        let baseGraph = graph.extractRendableChlid()!
        baseGraph.accept(visitor: visitor)
        
        graph.rect.size.width = baseGraph.rect.size.width + horizontalLength
        graph.rect.size.height = baseGraph.rect.size.height + verticalLength
        
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
extension _BorderModifier: ViewContentAcceptable {
    func accept(visitor: ViewContentVisitor) {
        guard let graph = visitor.current, let modifier = graph.anyView as? HasAnyModifier, modifier.anyModifier is _BorderModifier else {
            fatalError("visitor.current should _BorderModifier type but actually type of \(type(of: visitor.current))")
        }
        let position = graph.positionToWindow()
        
        topBorder: do {
            sharedCursor.moveTo(point: position)
            visitor.driver.add(string: Edge.Set.leadingTop.defaultDelimiter)
            stride(from: position.x + 1, to: position.x + 1 + graph.rect.size.width, by: Edge.Set.horizontal.defaultDelimiter.width).forEach { _ in
                visitor.driver.add(string: Edge.Set.horizontal.defaultDelimiter)
            }
            visitor.driver.add(string: Edge.Set.trailingTop.defaultDelimiter)
        }

        sideBorder: do {
            stride(from: position.y + 1, to: position.y + 1 + graph.rect.size.height - 1, by: Edge.Set.vertical.defaultDelimiter.height).forEach { offset in
                sharedCursor.moveTo(x: position.x, y: position.y + 1 + offset)
                visitor.driver.add(string: Edge.Set.vertical.defaultDelimiter)
                
                sharedCursor.moveTo(x: position.x + graph.rect.size.width, y: position.y + 1 + offset)
                visitor.driver.add(string: Edge.Set.vertical.defaultDelimiter)
            }
        }
        
        bottomBorder: do {
            sharedCursor.moveTo(x: position.x, y: position.y + graph.rect.size.height)
            visitor.driver.add(string: Edge.Set.leadingBottom.defaultDelimiter)
            stride(from: position.x + 1, to: position.x + 1 + graph.rect.size.width, by: Edge.Set.horizontal.defaultDelimiter.width).forEach { _ in
                visitor.driver.add(string: Edge.Set.horizontal.defaultDelimiter)
            }
            visitor.driver.add(string: Edge.Set.trailingBottom.defaultDelimiter)
        }
    }
}

extension View {
    @inlinable public func border(color: Color? = nil, insets: EdgeInsets) -> some View {
        modifier(_BorderModifier(color: color, edges: .all, insets: insets))
    }
    @inlinable public func border(color: Color? = nil, edges: Edge.Set = .all, width: PhysicalDistance? = nil) -> some View {
        let insets = width.map { EdgeInsets(_all: $0) }
        return modifier(_BorderModifier(color: color, edges: edges, insets: insets))
    }
    @inlinable public func border(color: Color? = nil, edges: Edge.Set = .all) -> some View {
        modifier(_BorderModifier(color: color, edges: edges, insets: nil))
    }
}
