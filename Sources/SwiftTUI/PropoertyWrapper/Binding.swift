//
//  Binding.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2020/04/06.
//

import Foundation

@propertyWrapper @dynamicMemberLookup public struct Binding<Value> {
    private var valueContainer: PropertyWrapperValueContainer<Value>
    internal var location: AnyLocation<Value>
    internal init(location: AnyLocation<Value>) {
        self.location = location
        self.valueContainer = PropertyWrapperValueContainer(value: location.value)
    }
    public init(get: @escaping () -> Value, set: @escaping (Value) -> Swift.Void) {
        self.init(location: LocationBox(FunctionalLocation.init(get: get, set: set)))
    }
    public static func constant(_ value: Value) -> Binding<Value> {
        Binding<Value>.init(location: LocationBox(ConstantLocation(value: value)))
    }
    public var wrappedValue: Value {
        get { return location.value }
        nonmutating set { location.value = newValue }
    }
    public var projectedValue: Binding<Value> { Binding<Value>.init(location: StoredLocation.init(value: location.value)) }
    public subscript<Subject>(dynamicMember keyPath: Swift.WritableKeyPath<Value, Subject>) -> Binding<Subject> {
        return Binding<Subject>.init(location: StoredLocation.init(value: location.value[keyPath: keyPath]))
    }
}

extension Binding: DynamicProperty where Value: Equatable {
    public func _inject(viewGraph: ViewGraph) {
        location.viewGraph = viewGraph
    }
    public func update() {
        if valueContainer.value == wrappedValue {
            return
        }
        valueContainer.value = wrappedValue
        
        renderMarker.reset()
        proposedSizeMarker.reset()
        
        // TODO: Implement specify graph
        sharedDrawer.draw()
    }
}
// TODO: Unknown usecases
//
//extension Binding {
//    public init<V>(_ base: Binding<V>) where Value == V?
//    public init?(_ base: Binding<Value?>)
//    public init<V>(_ base: Binding<V>) where Value == Swift.AnyHashable, V:  Swift.Hashable
//}
