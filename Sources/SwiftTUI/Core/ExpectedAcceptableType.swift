//
//  ExpectedAcceptable.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/24.
//

import Foundation

public enum _AcceptableType {
    case never
    case any
    case anyStorageBase
    case group
    case color
    case empty
    case font
    case text
    case tuple
    
    case modifier
    case _viewModifier_content
    case conditionalContent
    case variadicViewTree

    case hStack
    case vStack
}
