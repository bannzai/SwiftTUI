//
//  ViewModifier.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/18.
//

import Foundation

public struct _ViewModifier_Content<Modifier> where Modifier: ViewModifier {
    public typealias Body = Swift.Never
}

extension _ViewModifier_Content: View {
    public func _typeOf() -> _AcceptableType {
        .single(._viewModifier_content)
    }
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
