//
//  AnyView.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/07.
//

import Foundation

/// A type-erased `View`.
///
/// An `AnyView` allows changing the type of view used in a given view
/// hierarchy. Whenever the type of view used with an `AnyView`
/// changes, the old hierarchy is destroyed and a new hierarchy is
/// created for the new type.
public struct AnyView : View {
    // FIXME: Not use any
    let any: Any
    
    /// Create an instance that type-erases `view`.
    public init<V: View>(_ view: V) {
        self.any = view
    }

    public typealias Body = Never
}
