//
//  Color.swift
//  Demo
//
//  Created by Yudai.Hirose on 2019/11/06.
//

import Foundation

/// An environment-dependent color.
///
/// A `Color` is a late-binding token - its actual value is only resolved
/// when it is about to be used in a given environment. At that time it is
/// resolved to a concrete value.
public struct Color: Hashable {
    init() {
        
    }
}

extension Color: View {
    public typealias Body = Never
}

extension Color {
    /// A set of colors that are used by system elements and applications.
    public static let clear: Color = .init()
    public static let black: Color = .init()
    public static let white: Color = .init()
    public static let gray: Color = .init()
    public static let red: Color = .init()
    public static let green: Color = .init()
    public static let blue: Color = .init()
    public static let orange: Color = .init()
    public static let yellow: Color = .init()
    public static let pink: Color = .init()
    public static let purple: Color = .init()
    public static let primary: Color = .init()
    public static let secondary: Color = .init()
}
