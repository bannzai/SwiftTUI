//
//  DynamicProperty.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2020/04/06.
//

import Foundation

public protocol DynamicProperty {
    func _inject(viewGraph: ViewGraph)
    mutating func update()
}

extension DynamicProperty {
    func _inject(viewGraph: ViewGraph) {
        
    }
}
