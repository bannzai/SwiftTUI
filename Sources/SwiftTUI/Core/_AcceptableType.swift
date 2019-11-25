//
//  ExpectedAcceptable.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/24.
//

import Foundation

public enum _AcceptableType {
    public enum Single: CaseIterable {
        case never
        case any
        case anyStorageBase
        case group
        case color
        case empty
        case font
        case text
        case tuple
        
        case conditionalContent
        case variadicViewTree
    }
    public enum List: CaseIterable {
        case hStack
        case vStack
    }
    
    case single(Single)
    case list(List)

}
