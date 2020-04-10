//
//  State.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2020/04/08.
//

import Foundation

@propertyWrapper public struct State<Value> {
    @usableFromInline
    internal var _value: Value
    // NOTE: SwiftUI actually have optional location. but not have any idea immutable set _location
    @usableFromInline
    internal var _location: AnyLocation<Value>
    public init(wrappedValue value: Value) {
        self._value = value
        _location = StoredLocation(value: value)
    }
    public init(initialValue value: Value) {
        _value = value
        _location = StoredLocation(value: value)
    }
    public var wrappedValue: Value {
        get { return _location.value }
        nonmutating set { _location.value = newValue }
    }
    public var projectedValue: Binding<Value> {
        Binding<Value>(location: StoredLocation(value: wrappedValue))
    }
}

extension State: DynamicProperty where Value: Equatable {
    public func _inject(viewGraph: ViewGraph) {
        _location.viewGraph = viewGraph
    }
    
    mutating public func update() {
        if _value == wrappedValue {
            return
        }
        _value = wrappedValue
        
        renderMarker.reset()
        proposedSizeMarker.reset()
        
        // TODO: Implement specify graph
        sharedDrawer.draw()
    }
}

extension State where Value: Swift.ExpressibleByNilLiteral {
    @inlinable public init() {
        self.init(wrappedValue: nil)
    }
}
