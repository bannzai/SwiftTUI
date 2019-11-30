//
//  ViewModifier.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/28.
//

import Foundation

public struct _ViewModifier_Content<Modifier> where Modifier: ViewModifier {
    public typealias Body = Swift.Never
}

extension _ViewModifier_Content: View {
    public var _baseProperty: _ViewBaseProperties? { nil }
}

public protocol ViewModifier {
    associatedtype Body : View
    func body(content: Self.Content) -> Self.Body
    typealias Content = _ViewModifier_Content<Self>
}

extension ViewModifier where Body == Never {
    public func body(content: Self.Content) -> Self.Body {
        fatalError("body is never. received argument \(content)")
    }
}

internal protocol _ViewModifier {
    static var _keyPaths: [PartialKeyPath<_ViewBaseProperties>] { get }
    func modify<V: View>(view: V) -> V
}

@frozen public struct _BackgroundModifier<Background> : ViewModifier where Background : View {
  public var background: Background
  @inlinable public init(background: Background) {
        self.background = background
    }
  public typealias Body = Swift.Never
}
extension _BackgroundModifier : Swift.Equatable where Background : Swift.Equatable {
    public static func == (a: _BackgroundModifier<Background>, b: _BackgroundModifier<Background>) -> Swift.Bool {
        a.background == b.background
    }
}
extension View {
  @inlinable public func background<Background>(_ background: Background) -> some View where Background : View {
        return modifier(_BackgroundModifier(background: background))
    }
  
}

extension _BackgroundModifier: _ViewModifier {
    static var _keyPaths: [PartialKeyPath<_ViewBaseProperties>] {
        [\_ViewBaseProperties.backgroundColor]
    }
    
    func writableKeyPath<Value>(from keyPath: PartialKeyPath<_ViewBaseProperties>) -> ReferenceWritableKeyPath<_ViewBaseProperties, Value> {
        keyPath as! ReferenceWritableKeyPath<_ViewBaseProperties, Value>
    }
    
    func modify<V: View>(view: V) -> V {
        _BackgroundModifier._keyPaths.forEach { keyPath in
            switch background {
            case let color as Color:
                let a: ReferenceWritableKeyPath<_ViewBaseProperties, Color> = writableKeyPath(from: keyPath)
                view._baseProperty?[keyPath: a] = color
            case _:
                break
            }
        }
        return view
    }
}
