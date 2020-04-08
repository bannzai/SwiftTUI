//
//  AnyLocation.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2020/04/06.
//

import Foundation

@_hasMissingDesignatedInitializers @usableFromInline
internal class AnyLocationBase {
    var viewGraph: ViewGraph!
    convenience init() {
        self.init(viewGraph: nil)
    }
    init(viewGraph: ViewGraph?) {
        self.viewGraph = viewGraph
    }
}

@_inheritsConvenienceInitializers @_hasMissingDesignatedInitializers @usableFromInline
internal class AnyLocation<Value>: AnyLocationBase {
    // XXX: Escaping Segmentation fault: 11 error
    var value: Value {
        get { fatalError() }
        set { fatalError() }
    }
}

internal protocol _InnerLocationProperty: AnyObject {
    associatedtype Value
    var value: Value { get set }
}

internal final class StoredLocation<Value>: AnyLocation<Value>, _InnerLocationProperty {
    var _value: Value!
    
    convenience init(value: Value) {
        self.init()
        self._value = value
    }
    
    override var value: Value {
        get { _value }
        set { _value = newValue }
    }
}

internal final class LocationBox<I: AnyLocationBase & _InnerLocationProperty>: AnyLocation<I.Value>, _InnerLocationProperty {
    typealias Value = I.Value
    var location: I!
    
    convenience init(_ location: I) {
        self.init()
        self.location = location
    }
    
    override var value: Value {
        get { location.value }
        set { location.value = newValue }
    }
}

internal final class FunctionalLocation<Value>: AnyLocation<Value>, _InnerLocationProperty {
    var getter: (() -> Value)!
    var setter: ((Value) -> Void)!
    
    convenience init(get: @escaping () -> Value, set: @escaping (Value) -> Void) {
        self.init()
        self.getter = get
        self.setter = set
    }
    
    override var value: Value {
        get { getter() }
        set { setter(newValue) }
    }
}

internal final class ConstantLocation<Value>: AnyLocation<Value>, _InnerLocationProperty {
    var _value: Value!
    
    convenience init(value: Value) {
        self.init()
        self._value = value
    }
    
    override var value: Value {
        get { _value }
        set { _value = newValue }
    }
}
