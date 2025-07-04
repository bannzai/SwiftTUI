/// SwiftUI風の宣言的構文を可能にするresult builder
@resultBuilder
public struct ViewBuilder {
    // 単一のView
    public static func buildBlock<Content: View>(_ content: Content) -> Content {
        content
    }
    
    // 2つのView
    public static func buildBlock<C0: View, C1: View>(_ c0: C0, _ c1: C1) -> TupleView<(C0, C1)> {
        TupleView((c0, c1))
    }
    
    // 3つのView
    public static func buildBlock<C0: View, C1: View, C2: View>(_ c0: C0, _ c1: C1, _ c2: C2) -> TupleView<(C0, C1, C2)> {
        TupleView((c0, c1, c2))
    }
    
    // 4つのView
    public static func buildBlock<C0: View, C1: View, C2: View, C3: View>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3) -> TupleView<(C0, C1, C2, C3)> {
        TupleView((c0, c1, c2, c3))
    }
    
    // 5つのView
    public static func buildBlock<C0: View, C1: View, C2: View, C3: View, C4: View>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4) -> TupleView<(C0, C1, C2, C3, C4)> {
        TupleView((c0, c1, c2, c3, c4))
    }
    
    // 条件分岐サポート
    public static func buildEither<TrueContent: View, FalseContent: View>(first: TrueContent) -> ConditionalContent<TrueContent, FalseContent> {
        .first(first)
    }
    
    public static func buildEither<TrueContent: View, FalseContent: View>(second: FalseContent) -> ConditionalContent<TrueContent, FalseContent> {
        .second(second)
    }
    
    // オプショナルサポート
    public static func buildOptional<Content: View>(_ content: Content?) -> Content? {
        content
    }
    
    // 空のブロック
    public static func buildBlock() -> EmptyView {
        EmptyView()
    }
}