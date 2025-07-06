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
            // 型名でConditionalContentを検出
            let viewTypeName = String(describing: type(of: view))
            if viewTypeName.hasPrefix("ConditionalContent<") {
                return renderConditionalContentGeneric(view)
            }
            
            // 型名でModifiedContentを検出
            let typeName = String(describing: type(of: view))
            if typeName.hasPrefix("ModifiedContent<") {
                return renderModifiedContent(view)
            }
            
            // 型名でTupleViewを検出
            if typeName.hasPrefix("TupleView<") {
                return renderTupleViewGeneric(view)
            }
            
            // ForEachExpandedの検出
            if let forEachExpanded = view as? _ForEachExpandedProtocol {
                return renderForEachExpanded(forEachExpanded)
            }
            
            // ScrollViewの検出
            if typeName.hasPrefix("ScrollView<") {
                return renderScrollView(view)
            }
            
            // Listの検出
            if typeName.hasPrefix("List<") {
                return renderList(view)
            }
            
            
            // _layoutViewプロパティを持つViewの処理
            // VStackやHStackは_layoutViewプロパティを持っている
            // Mirrorで_layoutViewプロパティを探す
            let mirror = Mirror(reflecting: view)
            if let layoutViewChild = mirror.children.first(where: { $0.label == "_layoutView" }),
               let layoutView = layoutViewChild.value as? any LayoutView {
                return layoutView
            }
            
            // _layoutViewが見つからない場合のフォールバック
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
    
    /// ConditionalContentの変換（ジェネリック版）
    private static func renderConditionalContentGeneric<V: View>(_ view: V) -> any LayoutView {
        // Mirror経由でenumケースを判定
        let mirror = Mirror(reflecting: view)
        
        // ConditionalContentのミラーは子要素を1つ持つ
        if let child = mirror.children.first {
            if let content = child.value as? any View {
                return renderView(content)
            }
        }
        
        return EmptyView._LayoutView()
    }
    
    /// VStackやHStackの特別な処理
    private static func renderStackView<V: View>(_ view: V) -> any LayoutView {
        let typeName = String(describing: type(of: view))
        
        // VStackの処理
        if typeName.hasPrefix("VStack<") {
            // VStackは既に_layoutViewプロパティを持っている
            if let vstack = view as? VStack<AnyView> {
                return vstack._layoutView
            }
            // Mirror経由でcontent, spacingにアクセス
            let mirror = Mirror(reflecting: view)
            if let contentChild = mirror.children.first(where: { $0.label == "content" }),
               let content = contentChild.value as? any View {
                let spacing = mirror.children.first(where: { $0.label == "spacing" })?.value as? Int ?? 0
                let contentLayoutView = renderView(content)
                return CellFlexStack(.column, spacing: Float(spacing)) {
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
            // HStackは既に_layoutViewプロパティを持っている
            if let hstack = view as? HStack<AnyView> {
                return hstack._layoutView
            }
            // Mirror経由でcontent, spacingにアクセス
            let mirror = Mirror(reflecting: view)
            if let contentChild = mirror.children.first(where: { $0.label == "content" }),
               let content = contentChild.value as? any View {
                let spacing = mirror.children.first(where: { $0.label == "spacing" })?.value as? Int ?? 0
                let contentLayoutView = renderView(content)
                return CellFlexStack(.row, spacing: Float(spacing)) {
                    if let tupleLayoutView = contentLayoutView as? TupleLayoutView {
                        return tupleLayoutView.views
                    } else {
                        return [LegacyAnyView(contentLayoutView)]
                    }
                }
            }
        }
        
        // ButtonContainerの処理
        if typeName.hasPrefix("ButtonContainer<") {
            // Mirror経由でaction, label, idにアクセス
            let mirror = Mirror(reflecting: view)
            if let actionChild = mirror.children.first(where: { $0.label == "action" }),
               let labelChild = mirror.children.first(where: { $0.label == "label" }),
               let idChild = mirror.children.first(where: { $0.label == "id" }),
               let label = labelChild.value as? Text,
               let id = idChild.value as? String {
                return ButtonLayoutView<Text>(
                    action: actionChild.value as! () -> Void,
                    label: label,
                    id: id
                )
            }
        }
        
        // Toggleの処理
        if let toggle = view as? Toggle {
            return toggle._layoutView
        }
        
        // Pickerの処理
        if typeName.hasPrefix("Picker<") {
            // Mirror経由で_layoutViewプロパティを探す
            let mirror = Mirror(reflecting: view)
            if let layoutViewChild = mirror.children.first(where: { $0.label == "_layoutView" }),
               let layoutView = layoutViewChild.value as? any LayoutView {
                return layoutView
            }
        }
        
        // ProgressViewの処理
        if let progressView = view as? ProgressView {
            return progressView._layoutView
        }
        
        // Sliderの処理
        if typeName.hasPrefix("Slider<") {
            // Mirror経由で_layoutViewプロパティを探す
            let mirror = Mirror(reflecting: view)
            if let layoutViewChild = mirror.children.first(where: { $0.label == "_layoutView" }),
               let layoutView = layoutViewChild.value as? any LayoutView {
                return layoutView
            }
        }
        
        // Alertの処理
        if let alert = view as? Alert {
            return alert._layoutView
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
            let edges = paddingMirror.children.first(where: { $0.label == "edges" })?.value as? Edge.Set ?? .all
            let length = paddingMirror.children.first(where: { $0.label == "length" })?.value as? Int ?? 1
            
            // 全方向の場合は既存のPaddingLayoutViewを使用
            if edges == .all {
                return PaddingLayoutView(inset: Float(length), child: contentLayoutView)
            } else {
                // 方向指定の場合はDirectionalPaddingLayoutViewを使用
                return DirectionalPaddingLayoutView(edges: edges, length: Float(length), child: contentLayoutView)
            }
        } else if modifierTypeName.contains("BorderModifier") {
            // BorderModifierの処理
            // セルベースレンダリングを使用
            return CellBorderLayoutView(child: contentLayoutView)
        } else if modifierTypeName.contains("BackgroundModifier") {
            // BackgroundModifierの処理
            let bgMirror = Mirror(reflecting: modifierChild.value)
            if let bgChild = bgMirror.children.first(where: { $0.label == "background" }),
               let colorView = bgChild.value as? Color.ColorView {
                let colorMirror = Mirror(reflecting: colorView)
                if let colorChild = colorMirror.children.first(where: { $0.label == "color" }),
                   let color = colorChild.value as? Color {
                    // セルベースレンダリングを使用
                    return CellBackgroundLayoutView(color: color, child: contentLayoutView)
                }
            }
        } else if modifierTypeName.contains("ForegroundColorModifier") {
            // ForegroundColorModifierの処理
            let fgMirror = Mirror(reflecting: modifierChild.value)
            if let colorChild = fgMirror.children.first(where: { $0.label == "color" }),
               let color = colorChild.value as? Color {
                return ForegroundColorLayoutView(color: color, child: contentLayoutView)
            }
        } else if modifierTypeName.contains("FrameModifier") {
            // FrameModifierの処理
            let frameMirror = Mirror(reflecting: modifierChild.value)
            let width = frameMirror.children.first(where: { $0.label == "width" })?.value as? Float
            let height = frameMirror.children.first(where: { $0.label == "height" })?.value as? Float
            let alignment = frameMirror.children.first(where: { $0.label == "alignment" })?.value as? Alignment ?? .center
            return FrameLayoutView(width: width, height: height, alignment: alignment, child: contentLayoutView)
        }
        
        // 未対応のmodifierはcontentをそのまま返す
        return contentLayoutView
    }
    
    /// ForEachExpandedの変換
    private static func renderForEachExpanded(_ forEachExpanded: _ForEachExpandedProtocol) -> any LayoutView {
        let views = forEachExpanded._views.map { view in
            LegacyAnyView(renderView(view))
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
    
    /// ScrollViewの処理
    private static func renderScrollView<V: View>(_ view: V) -> any LayoutView {
        // ScrollViewは_layoutViewプロパティを持つはず
        if let scrollView = view as? ScrollView<AnyView> {
            return scrollView._layoutView
        }
        
        // Mirror経由でプロパティにアクセス
        let mirror = Mirror(reflecting: view)
        if let axesChild = mirror.children.first(where: { $0.label == "axes" }),
           let axes = axesChild.value as? Axis.Set,
           let showsIndicatorsChild = mirror.children.first(where: { $0.label == "showsIndicators" }),
           let showsIndicators = showsIndicatorsChild.value as? Bool,
           let contentChild = mirror.children.first(where: { $0.label == "content" }),
           let content = contentChild.value as? any View {
            let contentLayoutView = renderView(content)
            return ScrollLayoutView(
                axes: axes,
                showsIndicators: showsIndicators,
                child: contentLayoutView
            )
        }
        
        // 未対応の場合はEmptyView
        return EmptyView._LayoutView()
    }
    
    /// Listの処理
    private static func renderList<V: View>(_ view: V) -> any LayoutView {
        // Listは_layoutViewプロパティを持つはず
        if let list = view as? List<AnyView> {
            return list._layoutView
        }
        
        // Mirror経由でcontentにアクセス
        let mirror = Mirror(reflecting: view)
        if let contentChild = mirror.children.first(where: { $0.label == "content" }),
           let content = contentChild.value as? any View {
            let contentLayoutView = renderView(content)
            return ListLayoutView(child: contentLayoutView)
        }
        
        // 未対応の場合はEmptyView
        return EmptyView._LayoutView()
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
internal final class TupleLayoutView: LayoutView {
    let views: [LegacyAnyView]
    private var calculatedNode: YogaNode?
    
    init(views: [LegacyAnyView]) {
        self.views = views
    }
    
    func makeNode() -> YogaNode {
        // 複数のViewを配列として保持するだけ
        // 実際の配置はVStackやHStackで決定される
        let node = YogaNode()
        node.flexDirection(.column)
        for view in views {
            node.insert(child: view.makeNode())
        }
        self.calculatedNode = node
        return node
    }
    
    func paint(origin: (x: Int, y: Int), into buffer: inout [String]) {
        // Use the calculated node if available, otherwise create a new one
        let node = calculatedNode ?? makeNode()
        
        // If we don't have layout information, we need to calculate it
        if YGNodeLayoutGetWidth(node.rawPtr) == 0 {
            // Fallback: calculate with a default width
            node.calculate(width: 80)
        }
        
        // Paint children at their calculated positions
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