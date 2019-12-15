//
//  View.swift
//  Demo
//
//  Created by Yudai.Hirose on 2019/10/22.
//

import Foundation


public struct Border {
    public let color: Color
    public let directionType: DirectionType
    
    @inlinable public init(color: Color, directionType: DirectionType) {
        self.color = color
        self.directionType = directionType
    }
    
    public enum DirectionType: Int8 {
        case top, left, right, bottom
        case all
        
        public static let `default`: DirectionType = .all
    }
}
public class _ViewBaseProperties {
    init() { }
    internal var rect: Rect? = nil

    internal var backgroundColor: Color = Style.Color.background.color
    
    internal var border: Border? = nil
}

/// A piece of user interface.
///
/// You create custom views by declaring types that conform to the `View`
/// protocol. Implement the required `body` property to provide the content
/// and behavior for your custom view.
public protocol View {
    
    var _baseProperty: _ViewBaseProperties? { get }

    /// The type of view representing the body of this view.
    ///
    /// When you create a custom view, Swift infers this type from your
    /// implementation of the required `body` property.
    associatedtype Body : View

    /// Declares the content and behavior of this view.
    var body: Self.Body { get }
}

extension View where Self.Body == Never {
    public var body: Self.Body {
        fatalError("Body is never")
    }
}

extension View {
    public var _baseProperty: _ViewBaseProperties? { _ViewBaseProperties() }
}
