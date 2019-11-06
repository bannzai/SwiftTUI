//
//  SwiftTUI+Never.swift
//  Demo
//
//  Created by Yudai.Hirose on 2019/11/06.
//

import Foundation

extension Never: View {

    /// The type of view representing the body of this view.
    ///
    /// When you create a custom view, Swift infers this type from your
    /// implementation of the required `body` property.
    public typealias Body = Never

    /// Declares the content and behavior of this view.
//    public var body: Never { fatalError("Body is never") }
}

extension View where Self.Body == Never {
    public var body: Self.Body {
        fatalError("Body is never")
    }
}
