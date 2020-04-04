//
//  BorderModifier.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/12/15.
//

import Foundation

extension Edge.Set {
    internal static let leadingTop: Edge.Set = [.leading, .top]
    internal static let trailingTop: Edge.Set = [.trailing, .top]
    internal static let leadingBottom: Edge.Set = [.leading, .bottom]
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
fileprivate let defaultBorderWidth: PhysicalDistance = 1
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
        
        if edges.contains(.leading) { baseGraph.rect.origin.x = (insets?.leading ?? defaultBorderWidth) }
        if edges.contains(.top) { baseGraph.rect.origin.y = (insets?.top ?? defaultBorderWidth) }
    }
    private func verticalLength() -> PhysicalDistance {
        var length = 0
        if edges.contains(.top) { length = length + (insets?.top ?? defaultBorderWidth) }
        if edges.contains(.bottom) { length = length + (insets?.bottom ?? defaultBorderWidth) }
        return length
    }
    private func horizontalLength() -> PhysicalDistance {
        var length = 0
        if edges.contains(.leading) { length = length + (insets?.leading ?? defaultBorderWidth) }
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
            let leading = position.x + 1
            let trailing = leading + graph.rect.size.width - 1
            stride(from: leading, to: trailing, by: Edge.Set.horizontal.defaultDelimiter.width).forEach { _ in
                visitor.driver.add(string: Edge.Set.horizontal.defaultDelimiter)
            }
            visitor.driver.add(string: Edge.Set.trailingTop.defaultDelimiter)
        }

        sideBorder: do {
            let top = position.y + 1
            let bottom = top + graph.rect.size.height - 1
            stride(from: top, to: bottom, by: Edge.Set.vertical.defaultDelimiter.height).forEach { offset in
                sharedCursor.moveTo(x: position.x, y: top + (offset - 1))
                visitor.driver.add(string: Edge.Set.vertical.defaultDelimiter)
                
                sharedCursor.moveTo(x: position.x + graph.rect.size.width, y: top + (offset - 1))
                visitor.driver.add(string: Edge.Set.vertical.defaultDelimiter)
            }
        }
        
        bottomBorder: do {
            sharedCursor.moveTo(x: position.x, y: position.y + graph.rect.size.height)
            visitor.driver.add(string: Edge.Set.leadingBottom.defaultDelimiter)
            let leading = position.x + 1
            let trailing = leading + graph.rect.size.width - 1
            stride(from: leading, to: trailing, by: Edge.Set.horizontal.defaultDelimiter.width).forEach { _ in
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
    @inlinable public func border(color: Color? = nil, edges: Edge.Set = .all) -> some View {
        modifier(_BorderModifier(color: color, edges: edges, insets: nil))
    }
}
