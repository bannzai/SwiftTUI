//
//  Alignment.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/24.
//

import Foundation

@frozen public struct Alignment : Swift.Equatable {
  public var horizontal: HorizontalAlignment
  public var vertical: VerticalAlignment
  @inlinable public init(horizontal: HorizontalAlignment, vertical: VerticalAlignment) {
        self.horizontal = horizontal
        self.vertical = vertical
    }
    public static func == (a: Alignment, b: Alignment) -> Swift.Bool {
        a.horizontal == b.horizontal && a.vertical == b.vertical
    }
}

extension Alignment {
    public static let center: Alignment = .init(horizontal: .center, vertical: .center)
    public static let leading: Alignment = .init(horizontal: .leading, vertical: .default)
    public static let trailing: Alignment = .init(horizontal: .trailing, vertical: .default)
    public static let top: Alignment = .init(horizontal: .default, vertical: .top)
    public static let bottom: Alignment = .init(horizontal: .default, vertical: .bottom)
    public static let topLeading: Alignment = .init(horizontal: .leading, vertical: .top)
    public static let topTrailing: Alignment = .init(horizontal: .trailing, vertical: .top)
    public static let bottomLeading: Alignment = .init(horizontal: .leading, vertical: .bottom)
    public static let bottomTrailing: Alignment = .init(horizontal: .trailing, vertical: .bottom)
}
