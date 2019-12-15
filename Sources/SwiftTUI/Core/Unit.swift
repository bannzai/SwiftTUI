//
//  Distance.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/12.
//

import Foundation

public typealias PhysicalDistance = Int

public struct Size {
    public var width: PhysicalDistance?
    public var height: PhysicalDistance?
    public init(width: PhysicalDistance?, height: PhysicalDistance?) {
        self.width = width
        self.height = height
    }
}

public struct Origin {
    public let x: PhysicalDistance?
    public let y: PhysicalDistance?
    public init(x: PhysicalDistance?, y: PhysicalDistance?) {
        self.x = x
        self.y = y
    }
}

