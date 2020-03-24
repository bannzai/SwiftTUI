//
//  View.swift
//  Demo
//
//  Created by Yudai.Hirose on 2019/10/22.
//

import Foundation

public let defaultBorderWidth: PhysicalDistance = 1
public struct Border {
    internal var color: Color
    internal var width: PhysicalDistance
    internal var directionType: DirectionType
    
    public init(color: Color, width: PhysicalDistance, directionType: DirectionType) {
        self.color = color
        self.width = width
        self.directionType = directionType
    }
    
    public enum DirectionType: Int8 {
        case top, left, right, bottom
        case all
        
        public static let `default`: DirectionType = .all
    }
}
public class _ViewBaseProperties {
    public init() { }
    internal var rect: Rect = Rect(origin: .zero, size: .zero)

    internal var backgroundColor: Color = Style.Color.background.color
    
    internal var border: Border? = nil
}

public protocol _View {
    var _wrappedViewForBuildGraph: _WrappedViewForBuildGraph { get }
}


/// A piece of user interface.
///
/// You create custom views by declaring types that conform to the `View`
/// protocol. Implement the required `body` property to provide the content
/// and behavior for your custom view.
public protocol View: _View {
    
    /// The type of view representing the body of this view.
    ///
    /// When you create a custom view, Swift infers this type from your
    /// implementation of the required `body` property.
    associatedtype Body : View

    /// Declares the content and behavior of this view.
    var body: Self.Body { get }
}

internal extension View {
    var isPrimitive: Bool {
        self is Primitive
    }
}

extension View where Self.Body == Never {
    public var body: Self.Body {
        fatalError("Body is never. dump view: \(self)")
    }
}

extension _View where Self: View {
    public var _wrappedViewForBuildGraph: _WrappedViewForBuildGraph {
        assert(!isPrimitive, "Should not call from Primitive view. type of \(type(of: self))")
        return _WrappedViewForBuildGraph(self)
    }
}

public struct _WrappedViewForBuildGraph: View, ViewGraphSetAcceptable {
    fileprivate class Storage<T: View>: AnyViewStorageBase {
        internal let view: T
        internal init(_ view: T) {
            self.view = view
        }
        internal override func accept(visitor: ViewGraphSetVisitor) -> ViewGraph {
            let graph = ViewGraphImpl(view: view)
            let keepCurrent = visitor.current
            defer { visitor.current = keepCurrent }
            visitor.current = graph
            graph.setCustomize(visitor.visit(view.body))
            return graph
        }
    }
    
    let storage: AnyViewStorageBase
    
    /// Create an instance that typeerases `view`.
    public init<V>(_ view: V) where V: View {
        self.storage = Storage(view)
    }
    
    internal func accept(visitor: ViewGraphSetVisitor) -> ViewGraph {
        storage.accept(visitor: visitor)
    }
}
