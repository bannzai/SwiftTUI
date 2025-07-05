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
      RenderLoop.scheduleRedraw() 
    }
  }
  
  public var projectedValue: Binding<Value> {
    Binding(
      get: { self.wrappedValue },
      set: { self.wrappedValue = $0 }
    )
  }
}

/// SwiftUIライクなBindingプロパティラッパー
@propertyWrapper
public struct Binding<Value> {
    private let getter: () -> Value
    private let setter: (Value) -> Void
    
    public init(get: @escaping () -> Value, set: @escaping (Value) -> Void) {
        self.getter = get
        self.setter = set
    }
    
    public var wrappedValue: Value {
        get { getter() }
        nonmutating set { setter(newValue) }
    }
    
    public var projectedValue: Binding<Value> {
        self
    }
}

// Binding便利初期化
public extension Binding {
    /// 固定値のBinding（読み取り専用）
    static func constant(_ value: Value) -> Binding<Value> {
        Binding(
            get: { value },
            set: { _ in }
        )
    }
}
