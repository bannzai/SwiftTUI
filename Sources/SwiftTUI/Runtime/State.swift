@propertyWrapper
public struct State<Value> {
  final class Box {
    var value: Value
    init(_ value: Value) { self.value = value }
  }

  private let box: Box

  public init(wrappedValue value: Value) {
    self.box = Box(value)
  }

  public var wrappedValue: Value {
    get { box.value }
    nonmutating set {
      box.value = newValue
      RenderLoop.redraw()
    }
  }
}
