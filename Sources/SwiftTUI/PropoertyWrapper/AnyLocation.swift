//
//  AnyLocation.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2020/04/06.
//

import Foundation

@_hasMissingDesignatedInitializers @usableFromInline
internal class AnyLocationBase {
    convenience init() { self.init(void: ()) }
    init(void: Void) { }
}

@_inheritsConvenienceInitializers @_hasMissingDesignatedInitializers @usableFromInline
internal class AnyLocation<Value>: AnyLocationBase {
    var value: Value
}

internal protocol _InnerLocation {
    associatedtype Value
    var value: Value { get set }
}

@_inheritsConvenienceInitializers @_hasMissingDesignatedInitializers
internal final class StoredLocation<Value>: AnyLocation<Value>, _InnerLocation {
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

@_inheritsConvenienceInitializers @_hasMissingDesignatedInitializers
internal final class LocationBox<I: AnyLocationBase & _InnerLocation>: AnyLocation<I.Value> {
    typealias Value = I.Value
    var location: I
    
    convenience init(_ location: I) {
        self.init()
        self.location = location
    }
    
    override var value: Value {
        get { location.value }
        set { location.value = newValue }
    }
}

@_inheritsConvenienceInitializers @_hasMissingDesignatedInitializers
internal final class FunctionalLocation<Value>: AnyLocation<Value>, _InnerLocation {
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

@_inheritsConvenienceInitializers @_hasMissingDesignatedInitializers
internal final class ConstantLocation<Value>: AnyLocation<Value>, _InnerLocation {
    var _value: Value!
    
    convenience init(value: Value) {
        self.init()
        self._value = value
    }
    
    override var value: Value {
        get { _value }
        set {  }
    }
}
