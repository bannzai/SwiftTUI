import Foundation
import yoga

/// SwiftUIライクなButton
public struct Button<Label: View>: View {
    private let action: () -> Void
    private let label: Label
    private let id = UUID().uuidString
    
    public init(action: @escaping () -> Void, @ViewBuilder label: () -> Label) {
        self.action = action
        self.label = label()
    }
    
    public var body: some View {
        ButtonContainer(action: action, label: label, id: id)
    }
}

// Stringラベル用の便利初期化（修正版）
public extension Button where Label == Text {
    init(_ title: String, action: @escaping () -> Void) {
        self.action = action
        self.label = Text(title)
    }
}

/// Buttonのコンテナビュー（フォーカス管理のため）
internal struct ButtonContainer<Content: View>: View {
    let action: () -> Void
    let label: Content
    private let computedId: String
    private let cachedLayoutView: any LayoutView
    
    var id: String { computedId }
    
    init(action: @escaping () -> Void, label: Content, id: String) {
        self.action = action
        self.label = label
        // Textラベルの場合、そのテキストをIDとして使用
        if let textLabel = label as? Text {
            let mirror = Mirror(reflecting: textLabel)
            if let textChild = mirror.children.first(where: { $0.label == "content" }),
               let text = textChild.value as? String {
                self.computedId = "Button-\(text)"
            } else {
                self.computedId = id
            }
        } else {
            self.computedId = id
        }
        
        // LayoutViewをキャッシュ
        self.cachedLayoutView = ButtonLayoutManager.shared.getOrCreate(
            id: computedId,
            action: action,
            label: label
        )
    }
    
    public typealias Body = Never
    
    internal var _layoutView: any LayoutView {
        return cachedLayoutView
    }
}

/// ButtonのLayoutView実装
internal class ButtonLayoutView<Content: View>: LayoutView, CellLayoutView, FocusableView {
    let action: () -> Void
    let label: Content
    let id: String
    private var isFocused = false
    private var labelLayoutView: any LayoutView
    private var yogaNode: YogaNode?  // Yogaノードを保持
    
    init(action: @escaping () -> Void, label: Content, id: String) {
        self.action = action
        self.label = label
        self.id = id
        self.labelLayoutView = ViewRenderer.renderView(label)
    }
    
    deinit {
        // FocusManagerから削除
        FocusManager.shared.unregister(id: id)
    }
    
    // MARK: - LayoutView
    
    func makeNode() -> YogaNode {
        // 毎回新しいノードを作成
        let node = YogaNode()
        
        // HStack内でサイズがゼロになる問題を回避するため、フレックス設定を追加
        node.setFlexShrink(0)  // 縮小を禁止
        node.setFlexGrow(0)    // 拡大を禁止
        
        // ラベルのレイアウトビューを更新（毎回新しく作成）
        self.labelLayoutView = ViewRenderer.renderView(label)
        
        // labelNodeを子として追加
        let labelNode = labelLayoutView.makeNode()
        node.insert(child: labelNode)
        
        // ボタンのパディングを設定
        node.setPadding(3, .left)
        node.setPadding(3, .right)
        node.setPadding(1, .top)
        node.setPadding(1, .bottom)
        
        // ノードを保存
        self.yogaNode = node
        
        // DEBUG
        if CellRenderLoop.DEBUG {
            print("[Button] makeNode called for button: \(id)")
            print("[Button]   Node address: \(node.rawPtr)")
            print("[Button]   Has children: \(YGNodeGetChildCount(node.rawPtr))")
        }
        
        return node
    }
    
    func paint(origin: (x: Int, y: Int), into buffer: inout [String]) {
        // paint時にFocusManagerに登録
        FocusManager.shared.register(self, id: id)
        
        // CellLayoutViewのデフォルト実装を使用
        var cellBuffer = CellBuffer(width: 200, height: 100)
        paintCells(origin: origin, into: &cellBuffer)
        
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
    
    func paintCells(origin: (x: Int, y: Int), into buffer: inout CellBuffer) {
        // paintCells時にFocusManagerに登録
        FocusManager.shared.register(self, id: id)
        
        // フォーカス時の色設定
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
    
    func setFocused(_ focused: Bool) {
        isFocused = focused
    }
    
    // 再レンダリング時の準備
    func prepareForRerender() {
        // ノードをクリアして、次のmakeNode()で新しく作成されるようにする
        // self.yogaNode = nil
        // TODO: これを有効にするとハングする問題がある
    }
    
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