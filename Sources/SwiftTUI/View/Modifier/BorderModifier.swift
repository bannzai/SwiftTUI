//
//  BorderModifier.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/12/15.
//

import Foundation

extension Edge.Set {
    fileprivate static let leadingTop: Edge.Set = [.leading, .top]
    fileprivate static let trailingTop: Edge.Set = [.trailing, .bottom]
    fileprivate static let leadingBottom: Edge.Set = [.leading, .top]
    fileprivate static let trailingBottom: Edge.Set = [.trailing, .bottom]
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

public struct Border {
    public let color: Color
    public let width: PhysicalDistance
    public let directionType: Edge.Set

    public init(color: Color?, width: PhysicalDistance, directionType: Edge.Set) {
        self.color = color ?? Style.Color.border.color
        self.width = width
        self.directionType = directionType
    }
}

@frozen public struct _BorderModifier: ViewModifier {
    @usableFromInline internal let border: Border
    
    public init(border: Border) {
        self.border = border
    }
    public typealias Body = Swift.Never
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
            stride(from: position.x, to: position.x + graph.rect.size.width, by: Edge.Set.horizontal.defaultDelimiter.width).forEach { _ in
                visitor.driver.add(string: Edge.Set.horizontal.defaultDelimiter)
            }
            visitor.driver.add(string: Edge.Set.trailingTop.defaultDelimiter)
        }

        sideBorder: do {
            stride(from: position.y + 1, to: position.y + graph.rect.size.height - 1, by: Edge.Set.vertical.defaultDelimiter.height).forEach { offset in
                sharedCursor.moveTo(x: position.x, y: position.y + 1 + offset)
                visitor.driver.add(string: Edge.Set.vertical.defaultDelimiter)
                
                sharedCursor.moveTo(x: position.x + graph.rect.size.width, y: position.y + 1 + offset)
                visitor.driver.add(string: Edge.Set.vertical.defaultDelimiter)
            }
        }
        
        bottomBorder: do {
            sharedCursor.moveTo(x: position.x, y: position.y + graph.rect.size.height)
            visitor.driver.add(string: Edge.Set.leadingBottom.defaultDelimiter)
            stride(from: position.x, to: position.x + graph.rect.size.width, by: Edge.Set.horizontal.defaultDelimiter.width).forEach { _ in
                visitor.driver.add(string: Edge.Set.horizontal.defaultDelimiter)
            }
            visitor.driver.add(string: Edge.Set.trailingBottom.defaultDelimiter)
        }
    }
}

extension View {
    @inlinable public func border(color: Color? = nil, width: PhysicalDistance = 1, direction: Edge.Set = .all) -> some View {
        modifier(_BorderModifier(border: Border(color: color, width: width, directionType: direction)))
    }
}
