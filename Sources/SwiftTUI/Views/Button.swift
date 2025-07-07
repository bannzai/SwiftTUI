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
private struct ButtonContainer<Content: View>: View {
    let action: () -> Void
    let label: Content
    let id: String
    
    init(action: @escaping () -> Void, label: Content, id: String) {
        self.action = action
        self.label = label
        // Textラベルの場合、そのテキストをIDとして使用
        if let textLabel = label as? Text {
            let mirror = Mirror(reflecting: textLabel)
            if let textChild = mirror.children.first(where: { $0.label == "content" }),
               let text = textChild.value as? String {
                self.id = "Button-\(text)"
            } else {
                self.id = id
            }
        } else {
            self.id = id
        }
    }
    
    public typealias Body = Never
    
    internal var _layoutView: any LayoutView {
        // ButtonLayoutManagerを使用してインスタンスを管理
        return ButtonLayoutManager.shared.getOrCreate(
            id: id,
            action: action,
            label: label
        )
    }
}

/// ButtonのLayoutView実装
internal class ButtonLayoutView<Content: View>: LayoutView, FocusableView {
    let action: () -> Void
    let label: Content
    let id: String
    private var isFocused = false
    private var labelLayoutView: any LayoutView
    
    init(action: @escaping () -> Void, label: Content, id: String) {
        self.action = action
        self.label = label
        self.id = id
        self.labelLayoutView = ViewRenderer.renderView(label)
        
        print("[ButtonLayoutView] init with id: \(id)")
        // FocusManagerに登録
        FocusManager.shared.register(self, id: id)
    }
    
    deinit {
        print("[ButtonLayoutView] deinit with id: \(id)")
        // FocusManagerから削除
        FocusManager.shared.unregister(id: id)
    }
    
    // MARK: - LayoutView
    
    func makeNode() -> YogaNode {
        let labelNode = labelLayoutView.makeNode()
        labelNode.calculate(width: 100) // 仮の幅で計算
        
        let width = YGNodeLayoutGetWidth(labelNode.rawPtr)
        let height = YGNodeLayoutGetHeight(labelNode.rawPtr)
        
        let node = YogaNode()
        node.setSize(width: width + 6, height: height + 2) // パディングと枠線分
        return node
    }
    
    func paint(origin: (x: Int, y: Int), into buffer: inout [String]) {
        // フォーカス時の色設定
        let borderColor = isFocused ? "\u{1B}[92m" : "\u{1B}[90m" // 緑（フォーカス時）またはグレー
        let fillColor = isFocused ? "\u{1B}[42m" : "" // 緑背景（フォーカス時のみ）
        let textColor = isFocused ? "\u{1B}[30m" : "" // 黒文字（フォーカス時のみ）
        let resetColor = "\u{1B}[0m"
        
        // 安全なFloat→Int変換
        func safeInt(_ v: Float) -> Int {
            v.isFinite ? Int(v) : 0
        }
        
        // ラベルのサイズを取得
        let labelNode = labelLayoutView.makeNode()
        labelNode.calculate(width: 100)
        let labelWidth = safeInt(YGNodeLayoutGetWidth(labelNode.rawPtr))
        let labelHeight = safeInt(YGNodeLayoutGetHeight(labelNode.rawPtr))
        
        // 上の枠線
        let topBorder = borderColor + "┌" + String(repeating: "─", count: labelWidth + 4) + "┐" + resetColor
        bufferWrite(row: origin.y, col: origin.x, text: topBorder, into: &buffer)
        
        // ラベル行
        for i in 0..<labelHeight {
            var line = borderColor + "│" + resetColor + fillColor + "  "
            
            // ラベルを一時バッファに描画
            var tempBuffer: [String] = Array(repeating: "", count: 100)
            labelLayoutView.paint(origin: (0, i), into: &tempBuffer)
            
            if i < tempBuffer.count && !tempBuffer[i].isEmpty {
                line += textColor + tempBuffer[i] + resetColor
            } else {
                line += String(repeating: " ", count: labelWidth)
            }
            
            line += fillColor + "  " + resetColor + borderColor + "│" + resetColor
            bufferWrite(row: origin.y + 1 + i, col: origin.x, text: line, into: &buffer)
        }
        
        // 下の枠線
        let bottomBorder = borderColor + "└" + String(repeating: "─", count: labelWidth + 4) + "┘" + resetColor
        bufferWrite(row: origin.y + labelHeight + 1, col: origin.x, text: bottomBorder, into: &buffer)
    }
    
    func render(into buffer: inout [String]) {
        // LayoutViewプロトコルの要件
    }
    
    // MARK: - FocusableView
    
    func setFocused(_ focused: Bool) {
        isFocused = focused
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