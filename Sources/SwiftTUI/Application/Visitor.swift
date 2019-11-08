//
//  Visitor.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/08.
//

import Foundation

// TODO: to internal type
open class Visitor {
    public init() { }
    open func visit<T>(_ element: T) {
        fatalError("Should override this method")
    }
}
