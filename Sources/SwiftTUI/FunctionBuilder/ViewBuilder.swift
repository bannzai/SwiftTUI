//
//  ViewBuilder.swift
//  Demo
//
//  Created by Yudai.Hirose on 2019/11/06.
//

import Foundation

@_functionBuilder public struct ViewBuilder {
    /// Builds an empty view from an block containing no statements, `{ }`.
    public static func buildBlock() -> EmptyView { EmptyView() }

    /// Passes a single view written as a child view (e..g, `{ Text("Hello") }`) through
    /// unmodified.
}

@available(OSX 10.15.0, *)
extension ViewBuilder {
    public struct _ConditionalContent<TrueContent, FalseContent>: View, Acceptable where TrueContent: View, FalseContent: View {
        enum Container {
            case truthy(TrueContent)
            case falsy(FalseContent)
            
            public var body: some View {
                switch self {
                case .truthy(let view):
                    return AnyView(view)
                case .falsy(let view):
                    return AnyView(view)
                }
            }
        }
        
        let storage: Container
        init(storage: Container) {
            self.storage = storage
        }
        
        public var _baseProperty: _ViewBaseProperties? {
            storage.body._baseProperty
        }
        
        public func accept<V>(visitor: V) -> AnyViewVisitor.VisitResult where V : AnyViewVisitor {
            storage.body.accept(visitor: visitor)
        }
        public func accept<V: AnyListViewVisitor>(visitor: V) -> AnyListViewVisitor.VisitResult {
            storage.body.accept(visitor: visitor)
        }
    }

    /// Provides support for "if" statements in multi-statement closures, producing an `Optional` view
    /// that is visible only when the `if` condition evaluates `true`.
    public static func buildIf<Content>(_ content: Content?) -> Content? where Content : View { content }

    /// Provides support for "if" statements in multi-statement closures, producing
    /// ConditionalContent for the "then" branch.
    public static func buildEither<TrueContent, FalseContent>(first: TrueContent) -> _ConditionalContent<TrueContent, FalseContent> where TrueContent : View, FalseContent : View { _ConditionalContent<TrueContent, FalseContent>(storage: .truthy(first)) }

    /// Provides support for "if-else" statements in multi-statement closures, producing
    /// ConditionalContent for the "else" branch.
    public static func buildEither<TrueContent, FalseContent>(second: FalseContent) -> _ConditionalContent<TrueContent, FalseContent> where TrueContent : View, FalseContent : View { _ConditionalContent<TrueContent, FalseContent>(storage: .falsy(second)) }
}

extension ViewBuilder {
    public static func buildBlock<Content>(_ content: Content) -> Content where Content : View { content }
    public static func buildBlock<C0, C1>(_ c0: C0, _ c1: C1) -> TupleView<(C0, C1)> where C0 : View, C1 : View { TupleView((c0, c1)) }
    public static func buildBlock<C0, C1, C2>(_ c0: C0, _ c1: C1, _ c2: C2) -> TupleView<(C0, C1, C2)> where C0 : View, C1 : View, C2 : View { TupleView((c0, c1, c2))}
    public static func buildBlock<C0, C1, C2, C3>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3) -> TupleView<(C0, C1, C2, C3)> where C0 : View, C1 : View, C2 : View, C3 : View { TupleView((c0, c1, c2, c3)) }
    public static func buildBlock<C0, C1, C2, C3, C4>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4) -> TupleView<(C0, C1, C2, C3, C4)> where C0 : View, C1 : View, C2 : View, C3 : View, C4 : View { TupleView((c0, c1, c2, c3, c4)) }
    public static func buildBlock<C0, C1, C2, C3, C4, C5>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5) -> TupleView<(C0, C1, C2, C3, C4, C5)> where C0 : View, C1 : View, C2 : View, C3 : View, C4 : View, C5 : View { TupleView((c0, c1, c2, c3, c4, c5)) }
    public static func buildBlock<C0, C1, C2, C3, C4, C5, C6>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6) -> TupleView<(C0, C1, C2, C3, C4, C5, C6)> where C0 : View, C1 : View, C2 : View, C3 : View, C4 : View, C5 : View, C6 : View { TupleView((c0, c1, c2, c3, c4, c5, c6)) }
    public static func buildBlock<C0, C1, C2, C3, C4, C5, C6, C7>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7) -> TupleView<(C0, C1, C2, C3, C4, C5, C6, C7)> where C0 : View, C1 : View, C2 : View, C3 : View, C4 : View, C5 : View, C6 : View, C7 : View { TupleView((c0, c1, c2, c3, c4, c5, c6, c7)) }
    public static func buildBlock<C0, C1, C2, C3, C4, C5, C6, C7, C8>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7, _ c8: C8) -> TupleView<(C0, C1, C2, C3, C4, C5, C6, C7, C8)> where C0 : View, C1 : View, C2 : View, C3 : View, C4 : View, C5 : View, C6 : View, C7 : View, C8 : View { TupleView((c0, c1, c2, c3, c4, c5, c6, c7, c8)) }
    public static func buildBlock<C0, C1, C2, C3, C4, C5, C6, C7, C8, C9>(_ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7, _ c8: C8, _ c9: C9) -> TupleView<(C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)> where C0 : View, C1 : View, C2 : View, C3 : View, C4 : View, C5 : View, C6 : View, C7 : View, C8 : View, C9 : View { TupleView((c0, c1, c2, c3, c4, c5, c6, c7, c8, c9)) }
}
