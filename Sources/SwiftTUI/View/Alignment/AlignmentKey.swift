//
//  AlignmentKey.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/12.
//

import Foundation

@usableFromInline @frozen internal struct AlignmentKey: Swift.Hashable, Swift.Comparable {
    private let bits: Swift.UInt
    init(bits: Swift.UInt) {
        self.bits = bits
    }
    @usableFromInline
    internal static func < (lhs: AlignmentKey, rhs: AlignmentKey) -> Swift.Bool {
        lhs.bits < rhs.bits
    }
    @usableFromInline
    internal static func == (lhs: AlignmentKey, rhs: AlignmentKey) -> Swift.Bool {
        lhs.bits == rhs.bits
    }
    @usableFromInline
    internal func hash(into hasher: inout Swift.Hasher) {
        hasher.combine(bits)
    }
}
