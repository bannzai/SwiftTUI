//
//  Visitor.swift
//  Demo
//
//  Created by Yudai.Hirose on 2019/11/08.
//

import Foundation

protocol Visitor {
    func visit<T>(_ element: T)
}
