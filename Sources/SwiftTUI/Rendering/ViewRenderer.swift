import Foundation
import yoga

/// ViewからLayoutViewへの変換を行う内部レンダラー
internal struct ViewRenderer {
    
    /// ViewをLayoutViewに変換
    static func renderView<V: View>(_ view: V) -> any LayoutView {
        // 型名を確認してModifiedContentを特別扱い
        let typeName = String(describing: type(of: view))
        if typeName.hasPrefix("ModifiedContent<") {
            return renderModifiedContent(view)
        }
        
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
            
        case let conditional as ConditionalContent<AnyView, AnyView>:
            return renderConditionalContent(conditional)
            
        default:
            // 型名でModifiedContentを検出
            let typeName = String(describing: type(of: view))
            if typeName.hasPrefix("ModifiedContent<") {
                return renderModifiedContent(view)
            }
            
            // 型名でTupleViewを検出
            if typeName.hasPrefix("TupleView<") {
                return renderTupleViewGeneric(view)
            }
            
            // VStackやHStackの場合は特別な処理
            return renderStackView(view)
        }
    }
    
    /// TupleViewの変換（ジェネリック版）
    private static func renderTupleViewGeneric<V: View>(_ view: V) -> any LayoutView {
        // Mirror経由でvalueプロパティにアクセス
        let mirror = Mirror(reflecting: view)
        guard let valueChild = mirror.children.first(where: { $0.label == "value" }) else {
            return EmptyView._LayoutView()
        }
        
        let valueMirror = Mirror(reflecting: valueChild.value)
        var views: [LegacyAnyView] = []
        
        for child in valueMirror.children {
            if let childView = child.value as? any View {
                let layoutView = renderView(childView)
                views.append(LegacyAnyView(layoutView))
            }
        }
        
        // 複数のViewをTupleLayoutViewでラップ
        if views.isEmpty {
            return EmptyView._LayoutView()
        } else if views.count == 1 {
            return views[0]
        } else {
            return TupleLayoutView(views: views)
        }
    }
    
    /// TupleViewの変換（型安全版 - 使用されない）
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
    
    /// VStackやHStackの特別な処理
    private static func renderStackView<V: View>(_ view: V) -> any LayoutView {
        let typeName = String(describing: type(of: view))
        
        // VStackの処理
        if typeName.hasPrefix("VStack<") {
            // Mirror経由でcontentにアクセス
            let mirror = Mirror(reflecting: view)
            if let contentChild = mirror.children.first(where: { $0.label == "content" }),
               let content = contentChild.value as? any View {
                let contentLayoutView = renderView(content)
                return FlexStack(.column) {
                    if let tupleLayoutView = contentLayoutView as? TupleLayoutView {
                        return tupleLayoutView.views
                    } else {
                        return [LegacyAnyView(contentLayoutView)]
                    }
                }
            }
        }
        
        // HStackの処理
        if typeName.hasPrefix("HStack<") {
            // Mirror経由でcontentにアクセス
            let mirror = Mirror(reflecting: view)
            if let contentChild = mirror.children.first(where: { $0.label == "content" }),
               let content = contentChild.value as? any View {
                let contentLayoutView = renderView(content)
                return FlexStack(.row) {
                    if let tupleLayoutView = contentLayoutView as? TupleLayoutView {
                        return tupleLayoutView.views
                    } else {
                        return [LegacyAnyView(contentLayoutView)]
                    }
                }
            }
        }
        
        // 未対応のViewはEmptyViewとして扱う
        return EmptyView._LayoutView()
    }
    
    /// ModifiedContentの変換
    private static func renderModifiedContent<V: View>(_ view: V) -> any LayoutView {
        // ModifiedContentはbodyを持つViewなので、bodyを経由する必要がある
        // しかし、ModifiedContentのbodyはmodifierのbodyを呼び出す
        // ここでは直接処理する
        
        // Mirror経由でcontent と modifier にアクセス
        let mirror = Mirror(reflecting: view)
        
        guard let contentChild = mirror.children.first(where: { $0.label == "content" }),
              let modifierChild = mirror.children.first(where: { $0.label == "modifier" }) else {
            return EmptyView._LayoutView()
        }
        
        // contentをLayoutViewに変換
        let contentView = contentChild.value as? any View ?? EmptyView()
        let contentLayoutView = renderView(contentView)
        
        // modifierの型を判定して適切なLayoutViewを返す
        let modifierTypeName = String(describing: type(of: modifierChild.value))
        
        if modifierTypeName.contains("PaddingModifier") {
            // PaddingModifierの処理
            let paddingMirror = Mirror(reflecting: modifierChild.value)
            let length = paddingMirror.children.first(where: { $0.label == "length" })?.value as? Int ?? 1
            return PaddingLayoutView(inset: Float(length), child: contentLayoutView)
        } else if modifierTypeName.contains("BorderModifier") {
            // BorderModifierの処理
            return BorderLayoutView(child: contentLayoutView)
        } else if modifierTypeName.contains("BackgroundModifier") {
            // BackgroundModifierの処理
            let bgMirror = Mirror(reflecting: modifierChild.value)
            if let bgChild = bgMirror.children.first(where: { $0.label == "background" }),
               let colorView = bgChild.value as? Color.ColorView {
                let colorMirror = Mirror(reflecting: colorView)
                if let colorChild = colorMirror.children.first(where: { $0.label == "color" }),
                   let color = colorChild.value as? Color {
                    return BackgroundLayoutView(color: color, child: contentLayoutView)
                }
            }
        } else if modifierTypeName.contains("ForegroundColorModifier") {
            // ForegroundColorModifierの処理
            let fgMirror = Mirror(reflecting: modifierChild.value)
            if let colorChild = fgMirror.children.first(where: { $0.label == "color" }),
               let color = colorChild.value as? Color {
                return ForegroundColorLayoutView(color: color, child: contentLayoutView)
            }
        }
        
        // 未対応のmodifierはcontentをそのまま返す
        return contentLayoutView
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