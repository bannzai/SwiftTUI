//
//  HasIntrinsicContentSize.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2020/04/19.
//

import Foundation

// e.g) Text, EmptyView
internal protocol HasIntrinsicContentSize {
    func intrinsicContentSize(viewGraph: ViewGraph, visitor: ViewSetRectVisitor) -> Size
}

