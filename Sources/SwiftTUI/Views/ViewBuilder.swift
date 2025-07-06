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
    
    // 6つのView
    public static func buildBlock<C0: View, C1: View, C2: View, C3: View, C4: View, C5: View>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5) -> TupleView<(C0, C1, C2, C3, C4, C5)> {
        TupleView((c0, c1, c2, c3, c4, c5))
    }
    
    // 7つのView
    public static func buildBlock<C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6) -> TupleView<(C0, C1, C2, C3, C4, C5, C6)> {
        TupleView((c0, c1, c2, c3, c4, c5, c6))
    }
    
    // 8つのView
    public static func buildBlock<C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7) -> TupleView<(C0, C1, C2, C3, C4, C5, C6, C7)> {
        TupleView((c0, c1, c2, c3, c4, c5, c6, c7))
    }
    
    // 9つのView
    public static func buildBlock<C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View, C8: View>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7, _ c8: C8) -> TupleView<(C0, C1, C2, C3, C4, C5, C6, C7, C8)> {
        TupleView((c0, c1, c2, c3, c4, c5, c6, c7, c8))
    }
    
    // 10つのView
    public static func buildBlock<C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View, C8: View, C9: View>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7, _ c8: C8, _ c9: C9) -> TupleView<(C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)> {
        TupleView((c0, c1, c2, c3, c4, c5, c6, c7, c8, c9))
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