/// Button：TUIのインタラクティブボタンコンポーネント
///
/// キーボード操作でアクションを実行できるボタンです。
/// SwiftUIと同様のインターフェイスを提供します。
///
/// 使用例：
/// ```swift
/// Button("OK") {
///     print("ボタンが押されました")
/// }
/// ```
///
/// TUI初心者向け解説：
/// - GUIと違いマウスクリックではなくキーボードで操作
/// - Tabキーでフォーカス移動、Enter/Spaceで決定
/// - フォーカス状態は色で表現（緑色の枠）
///
/// 実装の特徴：
/// - フォーカス管理はFocusManagerと連携
/// - ButtonContainerを介してLayoutViewをキャッシュ
/// - 再レンダリング時も状態を保持

import Foundation
import yoga

/// SwiftUIライクなButton
public struct Button<Label: View>: View {
    /// ボタンが押されたときに実行されるアクション
    private let action: () -> Void
    
    /// ボタンに表示されるラベル（Textなど）
    private let label: Label
    
    /// ボタンを一意に識別するID
    /// FocusManagerでのフォーカス管理に使用
    private let id = UUID().uuidString
    
    /// ボタンのイニシャライザ
    ///
    /// - Parameters:
    ///   - action: ボタンが押されたときのアクション
    ///   - label: ボタンのラベルを生成するクロージャ
    ///
    /// @ViewBuilderの説明：
    /// - 複数のViewを返せる特殊なクロージャ
    /// - if文やForEachも使用可能
    public init(action: @escaping () -> Void, @ViewBuilder label: () -> Label) {
        self.action = action
        self.label = label()
    }
    
    /// Buttonのbodyプロパティ
    ///
    /// ButtonContainerを返すことで、
    /// フォーカス管理とLayoutViewのキャッシュを実現
    public var body: some View {
        ButtonContainer(action: action, label: label, id: id)
    }
}

// Stringラベル用の便利初期化（修正版）
/// Buttonの便利なイニシャライザ（文字列ラベル用）
///
/// SwiftUIと同様の簡潔な書き方を提供します。
///
/// 使用例：
/// ```swift
/// Button("OK") {
///     print("OKボタンが押されました")
/// }
/// ```
///
/// where節の説明：
/// - Label == Text のときのみこのイニシャライザが使用可能
/// - 型安全にコンパイル時に判定される
public extension Button where Label == Text {
    init(_ title: String, action: @escaping () -> Void) {
        self.action = action
        self.label = Text(title)
    }
}

/// Buttonのコンテナビュー（フォーカス管理のため）
///
/// ButtonContainerの役割：
/// 1. ButtonLayoutViewのインスタンスをキャッシュ
/// 2. 再レンダリング時に同じインスタンスを再利用
/// 3. フォーカス状態を保持
///
/// TUI初心者向け解説：
/// - SwiftUIではViewは値型で毎回再作成される
/// - フォーカス状態などは失われてしまう
/// - ButtonContainerがLayoutViewをキャッシュして状態を保持
internal struct ButtonContainer<Content: View>: View {
    let action: () -> Void
    let label: Content
    
    /// 計算されたID（Textラベルの場合はテキストを含む）
    private let computedId: String
    
    /// キャッシュされたLayoutView
    /// ButtonLayoutManagerが管理し、再レンダリング時も保持
    private let cachedLayoutView: any LayoutView
    
    var id: String { computedId }
    
    init(action: @escaping () -> Void, label: Content, id: String) {
        self.action = action
        self.label = label
        
        // Textラベルの場合、そのテキストをIDとして使用
        // これにより同じテキストのボタンは同じIDを持つ
        //
        // Mirrorの説明：
        // - SwiftのリフレクションAPI
        // - 型の内部構造を調査できる
        // - Textのcontentプロパティを取得
        if let textLabel = label as? Text {
            let mirror = Mirror(reflecting: textLabel)
            if let textChild = mirror.children.first(where: { $0.label == "content" }),
               let text = textChild.value as? String {
                // "Button-OK" のような形式でIDを生成
                self.computedId = "Button-\(text)"
            } else {
                self.computedId = id
            }
        } else {
            self.computedId = id
        }
        
        // LayoutViewをキャッシュ
        // ButtonLayoutManagerはシングルトンで、
        // すべてのButtonLayoutViewを管理
        self.cachedLayoutView = ButtonLayoutManager.shared.getOrCreate(
            id: computedId,
            action: action,
            label: label
        )
    }
    
    /// ButtonContainerはプリミティブView
    /// bodyプロパティを持たず、直接LayoutViewに変換される
    public typealias Body = Never
    
    /// ViewRendererが使用する内部プロパティ
    /// キャッシュされたLayoutViewを返す
    internal var _layoutView: any LayoutView {
        return cachedLayoutView
    }
}

/// ButtonのLayoutView実装
///
/// ボタンの実際の描画とイベント処理を担当するクラス。
/// 複数のプロトコルを実装：
/// - LayoutView: レイアウト計算
/// - CellLayoutView: セルベース描画
/// - FocusableView: フォーカス管理
///
/// TUI初心者向け解説：
/// - classを使用（参照型）で状態を保持
/// - フォーカス状態によって表示が変わる
/// - キーボードイベントを処理してアクションを実行
internal class ButtonLayoutView<Content: View>: LayoutView, CellLayoutView, FocusableView {
    /// ボタンが押されたときのアクション
    let action: () -> Void
    
    /// ボタンのラベル（TextなどのView）
    let label: Content
    
    /// ボタンの一意識別子
    let id: String
    
    /// 現在のフォーカス状態
    /// trueのとき緑色の枠で表示
    private var isFocused = false
    
    /// ラベルのLayoutView
    /// ラベルを描画可能な形式に変換
    private var labelLayoutView: any LayoutView
    
    /// Yogaノードを保持
    /// レイアウト計算結果をキャッシュ
    private var yogaNode: YogaNode?
    
    /// ButtonLayoutViewのイニシャライザ
    ///
    /// ボタンの表示と動作に必要な情報を初期化します。
    ///
    /// - Parameters:
    ///   - action: ボタン押下時のアクション
    ///   - label: ボタンのラベル
    ///   - id: ボタンの一意識別子
    init(action: @escaping () -> Void, label: Content, id: String) {
        self.action = action
        self.label = label
        self.id = id
        // ラベルをLayoutViewに変換
        // ViewRendererが適切な型に変換
        self.labelLayoutView = ViewRenderer.renderView(label)
    }
    
    /// デイニシャライザ
    ///
    /// ボタンが破棄されるときにクリーンアップを実行。
    /// FocusManagerから登録を解除してメモリリークを防ぐ。
    deinit {
        // FocusManagerから削除
        FocusManager.shared.unregister(id: id)
    }
    
    // MARK: - LayoutView
    
    /// Yogaノードの作成
    ///
    /// ボタンのレイアウト情報を設定します。
    /// YogaはFacebook製のレイアウトエンジンで、
    /// Flexboxアルゴリズムでレイアウトを計算します。
    ///
    /// TUI初心者向け解説：
    /// - Yogaノード = レイアウト情報を持つオブジェクト
    /// - パディング、サイズ、位置などを管理
    /// - 子要素（ラベル）を含むツリー構造
    func makeNode() -> YogaNode {
        // 毎回新しいノードを作成
        let node = YogaNode()
        
        // HStack内でサイズがゼロになる問題を回避するため、フレックス設定を追加
        // フレックス設定の説明：
        // - setFlexShrink(0): コンテナが小さいときでも縮まない
        // - setFlexGrow(0): コンテナが大きいときでも拡大しない
        node.setFlexShrink(0)  // 縮小を禁止
        node.setFlexGrow(0)    // 拡大を禁止
        
        // ラベルのレイアウトビューを更新（毎回新しく作成）
        self.labelLayoutView = ViewRenderer.renderView(label)
        
        // labelNodeを子として追加
        // ボタンの中にラベルが表示される
        let labelNode = labelLayoutView.makeNode()
        node.insert(child: labelNode)
        
        // ボタンのパディングを設定
        // パディング = 枠線とテキストの間の余白
        // 左右: 3文字分、上下: 1文字分
        node.setPadding(3, .left)
        node.setPadding(3, .right)
        node.setPadding(1, .top)
        node.setPadding(1, .bottom)
        
        // ノードを保存
        // paintCellsで描画時に参照する
        self.yogaNode = node
        
        // DEBUG
        if CellRenderLoop.DEBUG {
            print("[Button] makeNode called for button: \(id)")
            print("[Button]   Node address: \(node.rawPtr)")
            print("[Button]   Has children: \(YGNodeGetChildCount(node.rawPtr))")
        }
        
        return node
    }
    
    /// 文字列バッファへの描画（互換性のため）
    ///
    /// CellLayoutViewのデフォルト実装を使用して、
    /// セルベース描画を文字列バッファに変換します。
    func paint(origin: (x: Int, y: Int), into buffer: inout [String]) {
        // paint時にFocusManagerに登録
        // これによりTabキーでフォーカス可能になる
        FocusManager.shared.register(self, id: id)
        
        // CellLayoutViewのデフォルト実装を使用
        // 一旦CellBufferに描画してからStringに変換
        var cellBuffer = CellBuffer(width: 200, height: 100)
        paintCells(origin: origin, into: &cellBuffer)
        
        // CellBufferをANSIエスケープ付き文字列に変換
        let lines = cellBuffer.toANSILines()
        for (index, line) in lines.enumerated() {
            let row = origin.y + index
            if row >= 0 {
                bufferWrite(row: row, col: origin.x, text: line, into: &buffer)
            }
        }
    }
    
    func render(into buffer: inout [String]) {
        // LayoutViewプロトコルの要件
    }
    
    // MARK: - CellLayoutView
    
    /// セルバッファへの描画（メインの描画メソッド）
    ///
    /// ボタンの枠線、背景、ラベルをセル単位で描画します。
    /// フォーカス状態によって色が変わります。
    ///
    /// 描画の流れ：
    /// 1. フォーカス状態に応じた色を決定
    /// 2. 枠線を描画（┌─┐│ │└─┘）
    /// 3. 背景色を塗る（フォーカス時）
    /// 4. ラベルを中央に描画
    func paintCells(origin: (x: Int, y: Int), into buffer: inout CellBuffer) {
        // paintCells時にFocusManagerに登録
        FocusManager.shared.register(self, id: id)
        
        // フォーカス時の色設定
        // フォーカスあり: 緑色の枠、緑色の背景、黒文字
        // フォーカスなし: 白色の枠、背景なし、白文字
        let borderColor: Color = isFocused ? .green : .white
        let fillColor: Color? = isFocused ? .green : nil
        let textColor: Color = isFocused ? .black : .white
        
        // 安全なFloat→Int変換
        func safeInt(_ v: Float) -> Int {
            v.isFinite ? Int(v) : 0
        }
        
        // 保存されたノードを使用
        guard let node = yogaNode else {
            // ノードが存在しない場合は何もしない
            // このケースはmakeNode()が呼ばれていないことを意味する
            if CellRenderLoop.DEBUG {
                print("[Button] WARNING: paintCells called without node for button: \(id)")
            }
            return
        }
        
        // DEBUG
        if CellRenderLoop.DEBUG {
            let width = YGNodeLayoutGetWidth(node.rawPtr)
            let height = YGNodeLayoutGetHeight(node.rawPtr)
            print("[Button] paintCells for button \(id) at (\(origin.x), \(origin.y)), size: \(width)x\(height)")
            print("[Button]   Node address: \(node.rawPtr)")
            print("[Button]   Has children: \(YGNodeGetChildCount(node.rawPtr))")
            if width == 0 || height == 0 {
                print("[Button]   WARNING: Size is 0, will not render!")
            }
        }
        
        let totalWidth = safeInt(YGNodeLayoutGetWidth(node.rawPtr))
        let totalHeight = safeInt(YGNodeLayoutGetHeight(node.rawPtr))
        
        // サイズが0の場合は描画しない
        if totalWidth == 0 || totalHeight == 0 {
            return
        }
        
        // 子ノード（ラベル）の情報を取得
        guard YGNodeGetChildCount(node.rawPtr) > 0,
              let labelRaw = YGNodeGetChild(node.rawPtr, 0) else { return }
        let labelWidth = safeInt(YGNodeLayoutGetWidth(labelRaw))
        let labelHeight = safeInt(YGNodeLayoutGetHeight(labelRaw))
        let labelLeft = safeInt(YGNodeLayoutGetLeft(labelRaw))
        let labelTop = safeInt(YGNodeLayoutGetTop(labelRaw))
        
        // 上の枠線
        bufferWriteCell(row: origin.y, col: origin.x, text: "┌", foregroundColor: borderColor, into: &buffer)
        for i in 1..<(totalWidth - 1) {
            bufferWriteCell(row: origin.y, col: origin.x + i, text: "─", foregroundColor: borderColor, into: &buffer)
        }
        bufferWriteCell(row: origin.y, col: origin.x + totalWidth - 1, text: "┐", foregroundColor: borderColor, into: &buffer)
        
        // 内容行
        for i in 0..<(totalHeight - 2) {
            // 左枠
            bufferWriteCell(row: origin.y + 1 + i, col: origin.x, text: "│", foregroundColor: borderColor, into: &buffer)
            
            // 背景色
            if let bg = fillColor {
                for j in 1..<(totalWidth - 1) {
                    bufferWriteCell(row: origin.y + 1 + i, col: origin.x + j, text: " ", backgroundColor: bg, into: &buffer)
                }
            }
            
            // 右枠
            bufferWriteCell(row: origin.y + 1 + i, col: origin.x + totalWidth - 1, text: "│", foregroundColor: borderColor, into: &buffer)
        }
        
        // ラベルを描画
        if let cellLayoutView = labelLayoutView as? CellLayoutView {
            let labelOrigin = (x: origin.x + labelLeft, y: origin.y + labelTop)
            
            // 一時バッファに描画してスタイルを適用
            var tempBuffer = CellBuffer(width: labelWidth, height: labelHeight)
            cellLayoutView.paintCells(origin: (0, 0), into: &tempBuffer)
            
            // tempBufferからコピー（フォーカス時のスタイルを適用）
            for row in 0..<labelHeight {
                for col in 0..<labelWidth {
                    if let cell = tempBuffer.getCell(row: row, col: col) {
                        var modifiedCell = cell
                        if fillColor != nil {
                            modifiedCell.foregroundColor = textColor
                            modifiedCell.backgroundColor = fillColor
                        }
                        buffer.setCell(row: labelOrigin.y + row, col: labelOrigin.x + col, cell: modifiedCell)
                    }
                }
            }
        }
        
        // 下の枠線
        bufferWriteCell(row: origin.y + totalHeight - 1, col: origin.x, text: "└", foregroundColor: borderColor, into: &buffer)
        for i in 1..<(totalWidth - 1) {
            bufferWriteCell(row: origin.y + totalHeight - 1, col: origin.x + i, text: "─", foregroundColor: borderColor, into: &buffer)
        }
        bufferWriteCell(row: origin.y + totalHeight - 1, col: origin.x + totalWidth - 1, text: "┘", foregroundColor: borderColor, into: &buffer)
    }
    
    // MARK: - FocusableView
    
    /// フォーカス状態の設定
    ///
    /// FocusManagerから呼ばれ、フォーカス状態を更新します。
    /// フォーカス状態が変わると再描画が必要です。
    func setFocused(_ focused: Bool) {
        isFocused = focused
    }
    
    /// 再レンダリング時の準備
    ///
    /// ButtonLayoutManagerから呼ばれ、
    /// 次のレンダリングに備えて状態をクリアします。
    func prepareForRerender() {
        // ノードをクリアして、次のmakeNode()で新しく作成されるようにする
        // self.yogaNode = nil
        // TODO: これを有効にするとハングする問題がある
    }
    
    /// キーボードイベントの処理
    ///
    /// フォーカスがあるときのみキーイベントを処理します。
    /// EnterまたはSpaceキーでアクションを実行します。
    ///
    /// - Parameter event: キーボードイベント
    /// - Returns: イベントを処理したかtrue
    ///
    /// TUI初心者向け解説：
    /// - GUIではマウスクリックでボタンを押す
    /// - TUIではEnterまたはSpaceキーでボタンを押す
    /// - Tabキーで次のボタンに移動
    func handleKeyEvent(_ event: KeyboardEvent) -> Bool {
        guard isFocused else { return false }
        
        switch event.key {
        case .enter, .space:
            // EnterまたはSpaceキーでアクションを実行
            action()
            return true
        default:
            return false
        }
    }
}