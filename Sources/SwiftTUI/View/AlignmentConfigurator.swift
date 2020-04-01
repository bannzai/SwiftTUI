//
//  AlignmentContext.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2020/04/01.
//

import Foundation

internal protocol AlignmentConfigurator {
    func configureAlignment(visitor: ViewSetRectVisitor)
}
