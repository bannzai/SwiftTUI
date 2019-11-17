//
//  ViewDimensions.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/12.
//

import Foundation

public struct ViewDimensions {
    public private(set) var width: PhysicalDistance = 0
    public private(set) var height: PhysicalDistance = 0
    
    public subscript(guide: HorizontalAlignment) -> PhysicalDistance {
        fatalError("TODO: Implement getter")
    }
    public subscript(guide: VerticalAlignment) -> PhysicalDistance {
        fatalError("TODO: Implement getter")
    }
    public subscript(explicit guide: HorizontalAlignment) -> PhysicalDistance? {
        fatalError("TODO: Implement getter")
    }
    public subscript(explicit guide: VerticalAlignment) -> PhysicalDistance? {
        fatalError("TODO: Implement getter")
    }
}
