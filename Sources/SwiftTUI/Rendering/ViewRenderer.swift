import Foundation
import yoga

/// ViewからLayoutViewへの変換を行う内部レンダラー
internal struct ViewRenderer {
    
    /// ViewをLayoutViewに変換
    static func renderView<V: View>(_ view: V) -> any LayoutView {
        // プリミティブViewの場合（Body == Never）
        if V.Body.self == Never.self {
            return renderPrimitiveView(view)
        }
        
        // bodyを持つViewの場合
        return renderView(view.body)
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
            
        case let spacer as Spacer:
            return spacer._layoutView
            
        case let tuple as TupleView<Any>:
            return renderTupleView(tuple)
            
        case let conditional as ConditionalContent<AnyView, AnyView>:
            return renderConditionalContent(conditional)
            
        default:
            // VStackやHStackなど、その他のプリミティブViewは_layoutViewを使用
            let typeName = String(describing: type(of: view))
            if typeName.hasPrefix("VStack<") ||
               typeName.hasPrefix("HStack<") {
                return (view as any View)._layoutView
            }
            
            // 未対応のViewはEmptyViewとして扱う
            return EmptyView._LayoutView()
        }
    }
    
    /// TupleViewの変換
    private static func renderTupleView<T>(_ tupleView: TupleView<T>) -> any LayoutView {
        let mirror = Mirror(reflecting: tupleView.value)
        var views: [LegacyAnyView] = []
        
        for child in mirror.children {
            if let childView = child.value as? any View {
                let layoutView = renderView(childView)
                views.append(LegacyAnyView(layoutView))
            }
        }
        
        // 複数のViewをFlexStackでラップ
        if views.isEmpty {
            return EmptyView._LayoutView()
        } else if views.count == 1 {
            return views[0]
        } else {
            // 複数のViewをFlexStackでラップして返す
            // VStackやHStackの内部では適切な方向に調整される
            return TupleLayoutView(views: views)
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

// TupleView用の内部LayoutView
internal struct TupleLayoutView: LayoutView {
    let views: [LegacyAnyView]
    
    func makeNode() -> YogaNode {
        // 複数のViewを配列として保持するだけ
        // 実際の配置はVStackやHStackで決定される
        let node = YogaNode()
        node.flexDirection(.column)
        for view in views {
            node.insert(child: view.makeNode())
        }
        return node
    }
    
    func paint(origin: (x: Int, y: Int), into buffer: inout [String]) {
        // 各子要素を描画
        let node = makeNode()
        let cnt = Int(YGNodeGetChildCount(node.rawPtr))
        for i in 0..<cnt {
            guard let raw = YGNodeGetChild(node.rawPtr, Int(i)) else { continue }
            let dx = Int(YGNodeLayoutGetLeft(raw))
            let dy = Int(YGNodeLayoutGetTop(raw))
            views[i].paint(origin: (origin.x + dx, origin.y + dy), into: &buffer)
        }
    }
    
    func render(into buffer: inout [String]) {
        // 各Viewをレンダリング
        for view in views {
            view.render(into: &buffer)
        }
    }
}