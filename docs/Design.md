# SwiftTUI新アーキテクチャ設計書

## 1. アーキテクチャ概要

### 現在のアーキテクチャ

```
┌────────────┐     ┌──────────────┐     ┌─────────────┐     ┌────────────────┐     ┌──────────┐
│    View    │ ──> │ ViewRenderer │ ──> │ LayoutView  │ ──> │ CellRenderLoop │ ──> │ Terminal │
└────────────┘     └──────────────┘     └─────────────┘     └────────────────┘     └──────────┘
    (Public)         (文字列型判定)         (内部実装)           (レンダリング)          (出力)
```

### 新アーキテクチャ

```
┌────────────────────┐     ┌─────────────┐     ┌────────────────┐     ┌──────────┐
│ View + RenderNode │ ──> │  ViewGraph  │ ──> │ CellRenderLoop │ ──> │ Terminal │
└────────────────────┘     └─────────────┘     └────────────────┘     └──────────┘
    (統合レイヤー)           (状態管理)           (レンダリング)          (出力)
```

## 2. コア設計

### 2.1 統合Viewプロトコル

```swift
/// 新しいViewプロトコル
public protocol View {
    associatedtype Body: View
    
    /// SwiftUIスタイルのbody
    @ViewBuilder var body: Body { get }
    
    /// レンダリングノードの生成（新規追加）
    func renderNode(context: RenderContext) -> RenderNode
}

/// プリミティブView用のデフォルト実装
extension View where Body == Never {
    public var body: Never {
        fatalError("Primitive view has no body")
    }
    
    /// プリミティブViewは直接RenderNodeを生成
    public func renderNode(context: RenderContext) -> RenderNode {
        // デフォルト実装
        // 各プリミティブViewがオーバーライド
        PrimitiveRenderNode(view: self, context: context)
    }
}

/// コンポジットView用のデフォルト実装
extension View where Body != Never {
    /// bodyを再帰的に処理
    public func renderNode(context: RenderContext) -> RenderNode {
        body.renderNode(context: context)
    }
}
```

### 2.2 RenderNodeシステム

```swift
/// レンダリングノードの基底クラス
public class RenderNode {
    /// ノードのユニークID
    let id: ObjectIdentifier
    
    /// 計算されたフレーム
    var frame: CGRect = .zero
    
    /// 子ノード
    var children: [RenderNode] = []
    
    /// レンダリング属性
    var attributes: RenderAttributes
    
    /// 前回のレンダリング結果（差分計算用）
    private var previousRender: CellBuffer?
    
    /// レイアウト計算
    func layout(constraints: LayoutConstraints) {
        // Yogaノードを内部で使用
        let yogaNode = makeYogaNode()
        yogaNode.calculateLayout(
            width: Float(constraints.maxWidth),
            height: Float(constraints.maxHeight)
        )
        applyYogaLayout(yogaNode)
    }
    
    /// セルバッファへのレンダリング
    func render(into buffer: inout CellBuffer) {
        renderContent(into: &buffer)
        for child in children {
            child.render(into: &buffer)
        }
    }
    
    /// 差分計算
    func diff(with previous: RenderNode?) -> [RenderPatch] {
        var patches: [RenderPatch] = []
        
        // フレームの変更
        if let previous = previous, frame != previous.frame {
            patches.append(.frameChanged(from: previous.frame, to: frame))
        }
        
        // 属性の変更
        if let previous = previous, attributes != previous.attributes {
            patches.append(.attributesChanged(from: previous.attributes, to: attributes))
        }
        
        // 子ノードの差分
        let childPatches = diffChildren(with: previous?.children ?? [])
        patches.append(contentsOf: childPatches)
        
        return patches
    }
    
    /// サブクラスでオーバーライド
    func renderContent(into buffer: inout CellBuffer) {
        // サブクラスで実装
    }
}

/// レンダリング属性
public struct RenderAttributes: Equatable {
    var foregroundColor: Color?
    var backgroundColor: Color?
    var bold: Bool = false
    var underline: Bool = false
    var padding: EdgeInsets = .zero
    var border: BorderStyle?
}

/// レンダリングコンテキスト
public struct RenderContext {
    /// 環境値
    let environment: EnvironmentValues
    
    /// 現在のフォーカス状態
    let focusState: FocusState
    
    /// アニメーション設定
    let animation: Animation?
    
    /// 再描画のトリガー
    let redrawTrigger: () -> Void
}
```

### 2.3 ViewGraph

```swift
/// View階層を管理するグラフ
public class ViewGraph {
    /// ルートノード
    private var rootNode: RenderNode?
    
    /// 前回のノード（差分計算用）
    private var previousNodes: [ObjectIdentifier: RenderNode] = [:]
    
    /// 状態管理
    private var stateStorage: StateStorage = StateStorage()
    
    /// Viewグラフの更新
    public func update<V: View>(with view: V) {
        let context = makeRenderContext()
        
        // 新しいノードツリーを生成
        let newRoot = view.renderNode(context: context)
        
        // レイアウト計算
        let constraints = LayoutConstraints(
            maxWidth: terminalWidth,
            maxHeight: terminalHeight
        )
        newRoot.layout(constraints: constraints)
        
        // 差分計算
        if let oldRoot = rootNode {
            let patches = newRoot.diff(with: oldRoot)
            applyPatches(patches)
        } else {
            // 初回レンダリング
            fullRender(newRoot)
        }
        
        // ノードを保存
        saveNodes(newRoot)
        rootNode = newRoot
    }
    
    /// レンダリング結果の取得
    public func render() -> CellBuffer {
        var buffer = CellBuffer(width: terminalWidth, height: terminalHeight)
        rootNode?.render(into: &buffer)
        return buffer
    }
    
    /// パッチの適用
    private func applyPatches(_ patches: [RenderPatch]) {
        // 最小限の再描画で更新
        for patch in patches {
            switch patch {
            case .frameChanged(let from, let to):
                clearRegion(from)
                drawRegion(to)
            case .attributesChanged:
                // 属性のみ更新
                updateAttributes()
            // その他のパッチタイプ
            }
        }
    }
}
```

### 2.4 具体的なView実装例

```swift
/// Text Viewの新実装
public struct Text: View {
    public typealias Body = Never
    
    private let content: String
    private var attributes: TextAttributes = TextAttributes()
    
    public init(_ content: String) {
        self.content = content
    }
    
    /// モディファイア
    public func foregroundColor(_ color: Color) -> Text {
        var copy = self
        copy.attributes.foregroundColor = color
        return copy
    }
    
    public func bold() -> Text {
        var copy = self
        copy.attributes.bold = true
        return copy
    }
    
    /// RenderNode生成
    public func renderNode(context: RenderContext) -> RenderNode {
        TextRenderNode(content: content, attributes: attributes, context: context)
    }
}

/// Text用のRenderNode
class TextRenderNode: RenderNode {
    let content: String
    let textAttributes: TextAttributes
    
    init(content: String, attributes: TextAttributes, context: RenderContext) {
        self.content = content
        self.textAttributes = attributes
        super.init()
        
        // RenderAttributesに変換
        self.attributes.foregroundColor = textAttributes.foregroundColor
        self.attributes.bold = textAttributes.bold
    }
    
    override func renderContent(into buffer: inout CellBuffer) {
        // 実際のテキストレンダリング
        let lines = content.split(separator: "\n")
        for (index, line) in lines.enumerated() {
            let y = Int(frame.origin.y) + index
            let x = Int(frame.origin.x)
            
            // 各文字をセルに配置
            for (charIndex, char) in line.enumerated() {
                let cell = Cell(
                    character: char,
                    foreground: attributes.foregroundColor ?? .default,
                    background: attributes.backgroundColor ?? .clear,
                    bold: attributes.bold
                )
                buffer.setCell(x: x + charIndex, y: y, cell: cell)
            }
        }
    }
}
```

## 3. 移行戦略

### Phase 1: 基盤整備（3週間）

1. **RenderNodeプロトコルの実装**
   - 基底クラスとプロトコルの定義
   - 基本的なレイアウト計算
   - 差分アルゴリズムの実装

2. **ViewGraphの実装**
   - ノード管理システム
   - 状態管理の統合
   - イベント処理パイプライン

3. **互換性レイヤー**
   - 既存LayoutViewのアダプター
   - 段階的移行のサポート

### Phase 2: コアView移行（4週間）

1. **基本View**
   - Text → TextRenderNode
   - Button → ButtonRenderNode
   - TextField → TextFieldRenderNode

2. **レイアウトView**
   - VStack/HStack → StackRenderNode
   - Spacer → SpacerRenderNode

3. **テスト更新**
   - 既存テストの修正
   - 新規テストの追加

### Phase 3: 全View移行（6週間）

1. **複雑なView**
   - List, ScrollView, ForEach
   - Picker, Toggle, Slider
   - Alert, ProgressView

2. **モディファイア**
   - すべてのViewModifierの移行
   - カスタムモディファイアサポート

3. **統合テスト**
   - E2Eテストの実施
   - パフォーマンステスト

### Phase 4: 最適化（2週間）

1. **コード削除**
   - ViewRenderer削除
   - LayoutViewプロトコル削除
   - 不要な変換層削除

2. **最適化**
   - メモリプロファイリング
   - レンダリング最適化
   - 差分計算の改善

### Phase 5: リリース準備（1週間）

1. **ドキュメント**
   - APIドキュメント更新
   - 移行ガイド作成
   - サンプルコード更新

2. **リリース**
   - ベータ版リリース
   - フィードバック収集
   - 最終調整

## 4. 技術的判断

### なぜクラスベースのRenderNode？

1. **参照セマンティクス**
   - ノード間の親子関係管理が容易
   - メモリ効率的な差分計算

2. **パフォーマンス**
   - 大規模な階層での値型コピーを回避
   - キャッシュの効率的な利用

### Yogaの内部化

1. **APIの安定性**
   - 公開APIからYogaを完全に隠蔽
   - 将来的な置き換えを可能に

2. **使いやすさ**
   - SwiftUIライクなAPIを維持
   - 複雑なレイアウト計算を隠蔽

## 5. 将来の拡張

### アニメーションサポート
```swift
Text("Hello")
    .foregroundColor(.green)
    .animation(.easeInOut(duration: 0.3))
```

### カスタムレイアウト
```swift
struct CustomLayout: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews) -> CGSize
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews)
}
```

### 非同期レンダリング
```swift
struct AsyncView: View {
    var body: some View {
        AsyncContent { phase in
            switch phase {
            case .loading:
                ProgressView()
            case .success(let data):
                DataView(data)
            case .failure(let error):
                ErrorView(error)
            }
        }
    }
}
```