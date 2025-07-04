import Foundation

/// ViewからLayoutViewへの変換を行う内部レンダラー
internal struct ViewRenderer {
    
    /// ViewをLayoutViewに変換
    static func renderView<V: View>(_ view: V) -> any LayoutView {
        // プリミティブViewの場合（Body == Never）
        if V.Body.self == Never.self {
            return renderPrimitiveView(view)
        }
        
        // bodyを持つViewの場合
        // 一時的にEmptyViewを返す（TODO: 実装）
        return EmptyView._LayoutView()
    }
    
    /// プリミティブViewの変換
    private static func renderPrimitiveView<V: View>(_ view: V) -> any LayoutView {
        switch view {
        case let anyView as AnyView:
            return anyView.makeLayoutView()
            
        case is EmptyView:
            return EmptyView._LayoutView()
            
        case let text as Text:
            return text._layoutView
            
        case let vstack as VStack<AnyView>:
            return vstack._layoutView
            
        case let hstack as HStack<AnyView>:
            return hstack._layoutView
            
        case let tuple as TupleView<Any>:
            return renderTupleView(tuple)
            
        case let conditional as ConditionalContent<AnyView, AnyView>:
            return renderConditionalContent(conditional)
            
        default:
            // 未対応のViewはEmptyViewとして扱う
            return EmptyView._LayoutView()
        }
    }
    
    /// TupleViewの変換
    private static func renderTupleView<T>(_ tupleView: TupleView<T>) -> any LayoutView {
        let mirror = Mirror(reflecting: tupleView.value)
        var views: [any LayoutView] = []
        
        for child in mirror.children {
            if let childView = child.value as? any View {
                views.append(renderView(childView))
            }
        }
        
        // 複数のViewをFlexStackでラップ（仮実装）
        // 一時的に最初のViewのみを使用
        if let first = views.first {
            return first
        } else {
            return EmptyView._LayoutView()
        }
    }
    
    /// ConditionalContentの変換
    private static func renderConditionalContent<T: View, F: View>(_ conditional: ConditionalContent<T, F>) -> any LayoutView {
        switch conditional {
        case .first(let content):
            return renderView(content)
        case .second(let content):
            return renderView(content)
        }
    }
}

// ViewにLayoutView変換機能を追加
extension View {
    /// 内部使用：ViewをLayoutViewに変換
    internal var _layoutView: any LayoutView {
        ViewRenderer.renderView(self)
    }
}