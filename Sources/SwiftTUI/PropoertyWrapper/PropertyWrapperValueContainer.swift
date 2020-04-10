//
//  PropertyWrappervalueContainer.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2020/04/10.
//

import Foundation


// NOTE: PropertyWrapperValueContainer is temporary class
// It should be access to in memory type of Property Conformance Record for State.value and Binding.value ...
// reference: https://github.com/apple/swift/blob/master/docs/ABI/TypeMetadata.rst#protocol-conformance-records
@usableFromInline internal class PropertyWrapperValueContainer<Value> {
    var value: Value
    init(value: Value) {
        self.value = value
    }
}
