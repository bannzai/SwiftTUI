//
//  AlignmentModifier.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/12/29.
//

import Foundation

@frozen public struct _AlignmentWritingModifier: ViewModifier {
    @usableFromInline internal let key: AlignmentKey
    @usableFromInline internal let computeValue: (ViewDimensions) -> PhysicalDistance
    @inlinable internal init(key: AlignmentKey, computeValue: @escaping (ViewDimensions) -> PhysicalDistance) {
        self.key = key
        self.computeValue = computeValue
    }
    public typealias Body = Swift.Never
}

extension View {
    @inlinable public func alignmentGuide(_ g: HorizontalAlignment, computeValue: @escaping (ViewDimensions) -> PhysicalDistance) -> some View {
          return modifier(
              _AlignmentWritingModifier(key: g.key, computeValue: computeValue))
      }
    
    @inlinable public func alignmentGuide(_ g: VerticalAlignment, computeValue: @escaping (ViewDimensions) -> PhysicalDistance) -> some View {
          return modifier(
              _AlignmentWritingModifier(key: g.key, computeValue: computeValue))
      }
}

extension _AlignmentWritingModifier: ViewContentAcceptable {
    func accept(visitor: ViewContentVisitor) {
        
    }
}

extension _AlignmentWritingModifier: ViewSetContentSizeVisitorAcceptable {
    func accept(visitor: ViewSetContentSizeVisitor) {
        let graph = visitor.current!
        assert(graph.children.count == 1, "it should want one child")
        let child = graph.children[0]
        visitor.visit(child)
        graph.contentSize = child.contentSize
    }
}

extension _AlignmentWritingModifier: Primitive { }
