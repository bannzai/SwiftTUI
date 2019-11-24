//
//  Font.swift
//  Demo
//
//  Created by Yudai.Hirose on 2019/11/06.
//

import Foundation

/// An environment-dependent font.
///
/// A `Font` is a late-binding token - its actual value is only resolved
/// when it is about to be used in a given environment. At that time it is
/// resolved to a concrete value.
public struct Font: Hashable {
    
}

extension Font: View {
    public typealias Body = Never
    public func _typeOf() -> _ExpectedAcceptableType {
        .font
    }
}

// MARK: - Font.Weight
extension Font {
    public enum Weight: Int, Hashable {
        case ultraLight
        case thin
        case light
        case regular
        case medium
        case semibold
        case bold
        case heavy
        case black
    }
}
