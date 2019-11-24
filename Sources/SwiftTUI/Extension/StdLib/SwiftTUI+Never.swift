//
//  SwiftTUI+Never.swift
//  Demo
//
//  Created by Yudai.Hirose on 2019/11/06.
//

import Foundation

extension Never: View {
    public typealias Body = Never
    public func _typeOf() -> _ExpectedAcceptableType {
        .never
    }
}
