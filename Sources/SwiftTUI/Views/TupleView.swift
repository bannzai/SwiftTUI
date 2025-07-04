/// 複数のViewをタプルとして保持するView
public struct TupleView<T>: View {
    let value: T
    
    public init(_ value: T) {
        self.value = value
    }
    
    public typealias Body = Never
}

// ConditionalContent: 条件分岐されたコンテンツ
public enum ConditionalContent<TrueContent: View, FalseContent: View>: View {
    case first(TrueContent)
    case second(FalseContent)
    
    public typealias Body = Never
}